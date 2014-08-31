class Report < ActiveRecord::Base
  include Authorizable
  include ReportCommon

  validates_lengths_from_database
  belongs_to_host
  has_many :messages, :through => :logs
  has_many :sources, :through => :logs
  has_many :logs, :dependent => :destroy
  has_one :environment, :through => :host
  has_one :hostgroup, :through => :host

  validates :host_id, :status, :presence => true
  validates :reported_at, :presence => true, :uniqueness => {:scope => :host_id}

  scoped_search :in => :host,        :on => :name,  :complete_value => true, :rename => :host
  scoped_search :in => :environment, :on => :name,  :complete_value => true, :rename => :environment
  scoped_search :in => :messages,    :on => :value,                          :rename => :log
  scoped_search :in => :sources,     :on => :value,                          :rename => :resource
  scoped_search :in => :hostgroup,   :on => :name,  :complete_value => true, :rename => :hostgroup
  scoped_search :in => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_fullname
  scoped_search :in => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_title

  scoped_search :on => :reported_at, :complete_value => true, :default_order => :desc,    :rename => :reported, :only_explicit => true
  scoped_search :on => :status, :offset => 0, :word_size => 4*BIT_NUM, :complete_value => {:true => true, :false => false}, :rename => :eventful

  scoped_search :on => :status, :offset => METRIC.index("applied"),         :word_size => BIT_NUM, :rename => :applied
  scoped_search :on => :status, :offset => METRIC.index("restarted"),       :word_size => BIT_NUM, :rename => :restarted
  scoped_search :on => :status, :offset => METRIC.index("failed"),          :word_size => BIT_NUM, :rename => :failed
  scoped_search :on => :status, :offset => METRIC.index("failed_restarts"), :word_size => BIT_NUM, :rename => :failed_restarts
  scoped_search :on => :status, :offset => METRIC.index("skipped"),         :word_size => BIT_NUM, :rename => :skipped
  scoped_search :on => :status, :offset => METRIC.index("pending"),         :word_size => BIT_NUM, :rename => :pending

  # returns reports for hosts in the User's filter set
  scope :my_reports, lambda {
    unless User.current.admin? and Organization.current.nil? and Location.current.nil?
      host_ids = Host.authorized(:view_hosts, Host).select("hosts.id").all
      where(:reports => {:host_id => host_ids})
    end
  }

  # returns recent reports
  scope :recent, lambda { |*args| where("reported_at > ?", (args.first || 1.day.ago)).order(:reported_at) }

  # with_changes
  scope :interesting, lambda { where("status <> 0") }

  # a method that save the report values (e.g. values from METRIC)
  # it is not supported to edit status values after it has been written once.
  def status=(st)
    s = case st
          when Integer, Fixnum
            st
          when Hash
            ReportStatusCalculator.new(:counters => st).calculate
          else
            raise Foreman::Exception(N_('Unsupported report status format'))
        end
    @calc = nil
    write_attribute(:status,s)
  end

  # extracts serialized metrics and keep them as a hash_with_indifferent_access
  def metrics
    YAML.load(read_attribute(:metrics)).with_indifferent_access
  end

  # serialize metrics as YAML
  def metrics= m
    write_attribute(:metrics,m.to_yaml) unless m.nil?
  end

  def to_label
    "#{host.name} / #{reported_at.to_s}"
  end

  def config_retrieval
    metrics[:time][:config_retrieval].round(2) rescue 0
  end

  def runtime
    (metrics[:time][:total] || metrics[:time].values.sum).round(2) rescue 0
  end

  def self.import(report, proxy_id = nil)
    ReportImporter.import(report, proxy_id)
  end

  # returns a hash of hosts and their recent reports metric counts which have values
  # e.g. non zero metrics.
  # first argument is time range, everything afterwards is a host list.
  # TODO: improve SQL query (so its not N+1 queries)
  def self.summarise(time = 1.day.ago, *hosts)
    list = {}
    raise ::Foreman::Exception.new(N_("invalid host list")) unless hosts
    hosts.flatten.each do |host|
      # set default of 0 per metric
      metrics = {}
      METRIC.each {|m| metrics[m] = 0 }
      host.reports.recent(time).all(:select => "status").each do |r|
        metrics.each_key do |m|
          metrics[m] += r.status(m)
        end
      end
      list[host.name] = {:metrics => metrics, :id => host.id} if metrics.values.sum > 0
    end
    list
  end

  # add sort by report time
  def <=>(other)
    self.created_at <=> other.created_at
  end

  # Expire reports based on time and status
  # Defaults to expire reports older than a week regardless of the status
  def self.expire(conditions = {})
    timerange = conditions[:timerange] || 1.week
    status = conditions[:status]
    cond = "reports.created_at < \'#{(Time.now.utc - timerange).to_formatted_s(:db)}\'"
    cond += " and reports.status = #{status}" unless status.nil?

    Log.joins(:report).where(:report_id => Report.where(cond)).delete_all
    Message.where("id not IN (#{Log.select(:message_id).to_sql})").delete_all
    Source.where("id not IN (#{Log.select(:source_id).to_sql})").delete_all
    count = Report.where(cond).delete_all
    logger.info Time.now.to_s + ": Expired #{count} Reports"
    count
  end

  # represent if we have a report --> used to ensure consistency across host report state the report itself
  def no_report
    false
  end

  def summaryStatus
    return _("Failed")   if error?
    return _("Modified") if changes?
    _("Success")
  end

  # puppet report status table column name
  def self.report_status
    "status"
  end
end
