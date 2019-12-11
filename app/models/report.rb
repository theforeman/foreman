class Report < ApplicationRecord
  LOG_LEVELS = %w[debug info notice warning err alert emerg crit]

  prepend Foreman::STI
  include Authorizable
  include ConfigurationStatusScopedSearch

  validates_lengths_from_database
  belongs_to_host
  has_many :logs, :dependent => :destroy
  has_many :messages, :through => :logs
  has_many :sources, :through => :logs
  has_one :environment, :through => :host
  has_one :hostgroup, :through => :host

  has_one :organization, :through => :host
  has_one :location, :through => :host

  validates :host_id, :status, :presence => true
  validates :reported_at, :presence => true, :uniqueness => {:scope => [:host_id, :type]}

  def self.inherited(child)
    child.instance_eval do
      scoped_search :relation => :host,        :on => :name,  :complete_value => true, :rename => :host
      scoped_search :relation => :environment, :on => :name,  :complete_value => true, :rename => :environment
      scoped_search :relation => :organization, :on => :name, :complete_value => true, :rename => :organization
      scoped_search :relation => :location,    :on => :name,  :complete_value => true, :rename => :location
      scoped_search :relation => :messages,    :on => :value,                          :rename => :log, :only_explicit => true
      scoped_search :relation => :sources,     :on => :value,                          :rename => :resource, :only_explicit => true
      scoped_search :relation => :hostgroup,   :on => :name,  :complete_value => true, :rename => :hostgroup
      scoped_search :relation => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_fullname
      scoped_search :relation => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_title

      scoped_search :on => :reported_at, :complete_value => true, :default_order => :desc, :rename => :reported, :only_explicit => true, :aliases => [:last_report]
      scoped_search :on => :host_id,     :complete_value => false, :only_explicit => true
      scoped_search :on => :origin
    end
    super
  end

  # returns reports for hosts in the User's filter set
  scope :my_reports, lambda {
    if !User.current.admin? || Organization.expand(Organization.current).present? || Location.expand(Location.current).present?
      joins_authorized(Host, :view_hosts)
    end
  }

  # returns recent reports
  scope :recent, ->(*args) { where("reported_at > ?", (args.first || 1.day.ago)).order(:reported_at) }

  # with_changes
  scope :interesting, -> { where("status <> 0") }

  # extracts serialized metrics and keep them as a hash_with_indifferent_access
  def metrics
    return {} if self[:metrics].nil?
    YAML.load(read_metrics).with_indifferent_access
  end

  # serialize metrics as YAML
  def metrics=(m)
    self[:metrics] = m.to_h.to_yaml unless m.nil?
  end

  def to_label
    "#{host.name} / #{reported_at}"
  end

  # add sort by report time
  def <=>(other)
    self.created_at <=> other.created_at
  end

  def self.with_logging(model)
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    count = yield
    end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    if count
      rate = (count / (end_time - start_time)).to_i rescue 0
    else
      count, rate = 0, 0
    end
    Foreman::Logging.with_fields(expired_logs: count, expired_total: count, expire_rate: rate) do
      logger.info "Expired #{count} #{model} at rate #{rate} #{model}/sec"
    end
  end

  # Expire reports based on time and status
  # Defaults to expire reports older than a week regardless of the status
  # This method will IS very slow, use only from rake task.
  def self.expire(conditions, batch_size, sleep_time)
    timerange = conditions[:timerange] || 1.week
    status = conditions[:status]
    created = (Time.now.utc - timerange).to_formatted_s(:db)
    logger.info "Starting #{to_s.underscore.humanize.pluralize} expiration before #{created} status #{status || 'not set'} batch size #{batch_size} sleep #{sleep_time}"
    cond = "created_at < \'#{created}\'"
    cond += " and status = #{status}" unless status.nil?
    total_count = 0
    # find the first (oldest) report to be deleted
    report_id_max = where(cond).reorder('').maximum(:id)
    return unless report_id_max
    # delete log entries in batches
    loop do
      deleted = nil
      Report.transaction do
        with_logging("logs") do
          report_id_min = report_id_max - batch_size
          report_id_min = 0 if report_id_min < 0
          deleted = Log.unscoped.where("report_id <= #{report_id_max} AND report_id >= #{report_id_min}").reorder('').delete_all
          total_count += deleted
          deleted
        end
      end
      break if deleted.nil? || deleted < 1
      sleep sleep_time
    end
    # delete report entries in batches
    loop do
      deleted = nil
      Report.transaction do
        with_logging("reports") do
          report_id_min = report_id_max - batch_size
          report_id_min = 0 if report_id_min < 0
          deleted = self.unscoped.where("id <= #{report_id_max} AND id >= #{report_id_min}").reorder('').delete_all
          total_count += deleted
          deleted
        end
      end
      break if deleted.nil? || deleted < 1
      sleep sleep_time
    end
    # Delete orphan messages/sources when no reports are left - this is not efficient but we are getting rid of this soon
    with_logging("messages") do
      Message.unscoped.where("id not IN (#{Log.unscoped.select('DISTINCT message_id').to_sql})").delete_all
    end
    with_logging("sources") do
      Source.unscoped.where("id not IN (#{Log.unscoped.select('DISTINCT source_id').to_sql})").delete_all
    end
    total_count
  end

  # represent if we have a report --> used to ensure consistency across host report state the report itself
  def no_report
    false
  end

  def self.origins
    Foreman::Plugin.report_origin_registry.all_origins
  end

  private

  def read_metrics
    yml_hash = '!ruby/hash:ActiveSupport::HashWithIndifferentAccess'
    yml_params = /!ruby\/[\w-]+:ActionController::Parameters/

    metrics_attr = self[:metrics]
    metrics_attr.gsub!(yml_params, yml_hash)
    metrics_attr
  end
end
