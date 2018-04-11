class Report < ApplicationRecord
  LOG_LEVELS = %w[debug info notice warning err alert emerg crit]

  prepend Foreman::STI
  include Authorizable
  include ConfigurationStatusScopedSearch

  validates_lengths_from_database
  belongs_to_host
  has_many :messages, :through => :logs
  has_many :sources, :through => :logs
  has_many :logs, :dependent => :destroy
  has_one :environment, :through => :host
  has_one :hostgroup, :through => :host

  validates :host_id, :status, :presence => true
  validates :reported_at, :presence => true, :uniqueness => {:scope => [:host_id, :type]}

  def self.inherited(child)
    child.instance_eval do
      scoped_search :relation => :host,        :on => :name,  :complete_value => true, :rename => :host
      scoped_search :relation => :environment, :on => :name,  :complete_value => true, :rename => :environment
      scoped_search :relation => :messages,    :on => :value,                          :rename => :log, :only_explicit => true
      scoped_search :relation => :sources,     :on => :value,                          :rename => :resource, :only_explicit => true
      scoped_search :relation => :hostgroup,   :on => :name,  :complete_value => true, :rename => :hostgroup
      scoped_search :relation => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_fullname
      scoped_search :relation => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_title

      scoped_search :on => :reported_at, :complete_value => true, :default_order => :desc, :rename => :reported, :only_explicit => true
      scoped_search :on => :host_id,     :complete_value => false, :only_explicit => true
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
    write_attribute(:metrics, m.to_h.to_yaml) unless m.nil?
  end

  def to_label
    "#{host.name} / #{reported_at}"
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

    Log.where(:report_id => where(cond)).reorder('').delete_all
    Message.where("id not IN (#{Log.unscoped.select('DISTINCT message_id').to_sql})").delete_all
    Source.where("id not IN (#{Log.unscoped.select('DISTINCT source_id').to_sql})").delete_all
    count = where(cond).reorder('').delete_all
    logger.info Time.now.utc.to_s + ": Expired #{count} #{to_s.underscore.humanize.pluralize}"
    count
  end

  # represent if we have a report --> used to ensure consistency across host report state the report itself
  def no_report
    false
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
