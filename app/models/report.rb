class Report < ActiveRecord::Base
  include Authorization
  include ReportCommon

  belongs_to_host
  has_many :messages, :through => :logs
  has_many :sources, :through => :logs
  has_many :logs, :dependent => :destroy
  has_one :environment, :through => :host
  has_one :hostgroup, :through => :host

  validates_presence_of :host_id, :reported_at, :status
  validates_uniqueness_of :reported_at, :scope => :host_id

  scoped_search :in => :host,        :on => :name,  :complete_value => true, :rename => :host
  scoped_search :in => :environment, :on => :name,  :complete_value => true, :rename => :environment
  scoped_search :in => :messages,    :on => :value,                          :rename => :log
  scoped_search :in => :sources,     :on => :value,                          :rename => :resource
  scoped_search :in => :hostgroup,   :on => :name,  :complete_value => true, :rename => :hostgroup
  scoped_search :in => :hostgroup,   :on => :label, :complete_value => true, :rename => :hostgroup_fullname

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
    if User.current.admin? and Organization.current.nil? and Location.current.nil?
      { :conditions => "" }
    else
      #TODO: Remove pluck after upgrade to newer rails as it would be
      #done via INNER select automatically
      where(:reports => {:host_id => Host.my_hosts.select("hosts.id")})
    end
  }

  # returns recent reports
  scope :recent, lambda { |*args| {:conditions => ["reported_at > ?", (args.first || 1.day.ago)], :order => "reported_at"} }

  # with_changes
  scope :interesting, {:conditions => "status != 0"}

  # a method that save the report values (e.g. values from METRIC)
  # it is not supported to edit status values after it has been written once.
  def status=(st)
    s = st if st.is_a?(Integer)
    s = Report.calc_status st if st.is_a?(Hash)
    write_attribute(:status,s) unless s.nil?
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

  #imports a report hash into database
  def self.import(report)
    raise ::Foreman::Exception.new("Invalid report") unless report.is_a?(Hash)
    logger.info "processing report for #{report['host']}"

    # Find the host
    host = Host.find_by_certname report['host']
    host ||= Host.find_by_name report['host']
    host ||= Host.new :name => report['host']

    # Set the report time
    time = Time.parse(report['reported_at']).utc

    # convert report status to bit field
    st = calc_status(report['status'])

    # update host record
    # we update our host record, so we wont need to lookup the report information just
    # to display the host list / info
    # save our report time
    host.last_report = time if host.last_report.nil? or host.last_report.utc < time

    # we save the raw bit status value in our host too.
    host.puppet_status = st

    # we save the host without validation for two reasons:
    # 1. It might be auto imported, therefore might not be valid (e.g. missing partition table etc)
    # 2. We want this to be fast and light on the db.
    # at this point, the report is important, not the host
    host.save(:validate => false)

    # and save our report
    r = self.new(:host => host, :reported_at => time, :status => st, :metrics => report['metrics'])
    return r unless r.save
    # Store all Puppet message logs
    r.import_log_messages report
    # Check for errors
    r.inspect_report
    return r
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
    return list
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
    cond = "created_at < \'#{(Time.now.utc - timerange).to_formatted_s(:db)}\'"
    cond += " and status = #{status}" unless status.nil?
    # using find in batches to reduce the memory abuse
    # trying to be smart about how to delete reports and their associated data, so it would be
    # as fast as possible without a lot of performance penalties.
    count = 0
    Report.find_in_batches(:conditions => cond, :select => :id) do |reports|
      report_ids = reports.map &:id
      Log.delete_all({:report_id => report_ids})
      count += Report.delete_all({:id => report_ids})
    end
    # try to find all non used logs, messages and sources

    # first extract all information from our logs
    all_reports, used_messages, used_sources = [],[],[]
    Log.find_in_batches do |logs|
      logs.each do |log|
        all_reports << log.report_id unless log.report_id.blank?
        used_messages << log.message_id unless log.message_id.blank?
        used_sources << log.source_id unless log.source_id.blank?
      end
    end

    all_reports.uniq! ; used_messages.uniq! ; used_sources.uniq!

    # reports which have logs entries
    used_reports = Report.all(:select => :id, :conditions => {:id => all_reports}).map(&:id)

    orphaned_logs = all_reports - used_reports
    Log.delete_all({:report_id => orphaned_logs}) unless orphaned_logs.empty?

    all_messages = Message.all(:select => :id).map(&:id)
    orphaned_messages = all_messages - used_messages
    Message.delete_all({:id => orphaned_messages}) unless orphaned_messages.empty?

    all_sources = Source.all(:select => :id).map(&:id)
    orphaned_sources = all_sources - used_sources
    Source.delete_all({:id => orphaned_sources}) unless orphaned_sources.empty?

    logger.info Time.now.to_s + ": Expired #{count} Reports"
    return count
  end

  def import_log_messages report
    return if report['logs'].empty?
    report['logs'].each do |r|
      # Parse the API format
      level = r['log']['level']
      msg   = r['log']['messages']['message']
      src   = r['log']['sources']['source']

      message = Message.find_or_create msg
      source  = Source.find_or_create src

      # Symbols get turned into strings via the JSON API, so convert back here if it matches
      # and expected log level. Log objects can't be created without one, so raise if not
      raise ::Foreman::Exception.new("Invalid log level: #{level}") unless LOG_LEVELS.include? level
      log = Log.create :message_id => message.id, :source_id => source.id, :report_id => self.id, :level => level.to_sym
      log.errors.empty?
    end
  end

  def inspect_report
    if error?
      # found a report with errors
      # notify via email IF enabled is set to true
      logger.warn "#{report['host']} is disabled - skipping." and return if host.disabled?

      logger.debug "error detected, checking if we need to send an email alert"
      HostMailer.error_state(self).deliver if Setting[:failed_report_email_notification]
      # add here more actions - e.g. snmp alert etc
    end
  rescue => e
    logger.warn "failed to send failure email notification: #{e}"
  end

  # represent if we have a report --> used to ensure consistency across host report state the report itself
  def no_report
    false
  end

  def summaryStatus
    return _("Failed")   if error?
    return _("Modified") if changes?
    return _("Success")
  end

  private

  # converts a hash into a bit field
  # expects a metrics_to_hash kind of hash
  # see the report_processor for the implementation
  def self.calc_status (hash = {})
    st = 0
    hash.each do |type, value|
      value = value.to_i # JSON does everything as strings
      value = MAX if value > MAX # we store up to 2^BIT_NUM -1 values as we want to use only BIT_NUM bits.
      st |= value << (BIT_NUM*METRIC.index(type))
    end
    return st
  end

  def enforce_permissions operation
    # No one can edit a report
    return false if operation == "edit"

    # Anyone can create a report
    return true if operation == "create"
    return true if operation == "destroy" and User.current.allowed_to?(:destroy_reports)

    errors.add(:base, _("You do not have permission to %s this report") % operation)
    false
  end

  # puppet report status table column name
  def self.report_status
    "status"
  end
end
