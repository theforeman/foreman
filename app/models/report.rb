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
  has_one :hostgroup, :through => :host
  has_one :host_owner, through: :host, source: :owner, source_type: 'User'

  has_one :organization, :through => :host
  has_one :location, :through => :host

  validates :host_id, :status, :presence => true
  validates :reported_at, :presence => true, :uniqueness => {:scope => [:host_id, :type]}

  def self.inherited(child)
    child.instance_eval do
      scoped_search :relation => :host,         :on => :name,  :complete_value => true, :rename => :host
      scoped_search :relation => :host_owner,
        :on => :id,
        :complete_value => true,
        :rename => :host_owner_id,
        :only_explicit => true,
        :validator => ->(value) { ScopedSearch::Validators::INTEGER.call(value) },
        :value_translation => ->(value) { value == 'current_user' ? User.current.id : value },
        :special_values => %w[current_user]
      scoped_search :relation => :organization, :on => :name,  :complete_value => true, :rename => :organization
      scoped_search :relation => :location,     :on => :name,  :complete_value => true, :rename => :location
      scoped_search :relation => :messages,     :on => :value,                          :rename => :log, :only_explicit => true
      scoped_search :relation => :sources,      :on => :value,                          :rename => :resource, :only_explicit => true
      scoped_search :relation => :hostgroup,    :on => :name,  :complete_value => true, :rename => :hostgroup
      scoped_search :relation => :hostgroup,    :on => :title, :complete_value => true, :rename => :hostgroup_fullname
      scoped_search :relation => :hostgroup,    :on => :title, :complete_value => true, :rename => :hostgroup_title

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
    created_at <=> other.created_at
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
    report_ids = []
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    loop do
      Report.transaction do
        batch_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        report_ids = where(cond).reorder('').limit(batch_size).pluck(:id)
        if report_ids.count > 0
          log_count = Log.unscoped.where(:report_id => report_ids).reorder('').delete_all
          count = where(:id => report_ids).reorder('').delete_all
          total_count += count
          rate = (count / (Process.clock_gettime(Process::CLOCK_MONOTONIC) - batch_start_time)).to_i
          Foreman::Logging.with_fields(expired_logs: log_count, expired_total: count, expire_rate: rate) do
            logger.info "Expired #{count} reports and #{log_count} logs at rate #{rate} reports/sec"
          end
        end
      end
      # Delete orphan messages/sources when no reports are left
      if report_ids.blank?
        message_count = Message.unscoped.where.not(id: Log.unscoped.distinct.select('message_id')).delete_all
        source_count = Source.unscoped.where.not(id: Log.unscoped.distinct.select('source_id')).delete_all
        Foreman::Logging.with_fields(deleted_messages: message_count, expired_sources: source_count) do
          logger.info "Expired #{message_count} messages and #{source_count} sources"
        end
        break
      end
      sleep sleep_time
    end
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) / 60).to_i
    logger.info "Total expired reports #{total_count} in #{duration} min(s)"
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
