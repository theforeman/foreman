class ConfigReport < Report
  include Foreman::ObservableModel

  METRIC = %w[applied restarted failed failed_restarts skipped pending].freeze
  BIT_NUM = 10
  MAX = (1 << BIT_NUM) - 1 # maximum value per metric

  scoped_search :on => :status, :offset => 0, :word_size => 4 * BIT_NUM, :complete_value => {:true => true, :false => false}, :rename => :eventful

  scoped_search_status 'applied',         :on => :status, :rename => :applied
  scoped_search_status 'restarted',       :on => :status, :rename => :restarted
  scoped_search_status 'failed',          :on => :status, :rename => :failed
  scoped_search_status 'failed_restarts', :on => :status, :rename => :failed_restarts
  scoped_search_status 'skipped',         :on => :status, :rename => :skipped
  scoped_search_status 'pending',         :on => :status, :rename => :pending

  # search for a metric - e.g.:
  # Report.with("failed") --> all reports which have a failed counter > 0
  # Report.with("failed",20) --> all reports which have a failed counter > 20
  scope :with, lambda { |*arg|
                 cond = "(#{report_status_column} >> #{HostStatus::ConfigurationStatus.bit_mask(arg[0].to_s)}) > #{arg[1] || 0}"
                 where(sanitize_sql(cond))
               }

  class << self
    delegate :model_name, :to => :superclass
  end

  set_crud_hooks :config_report

  apipie :class do
    name 'Configuration Report'
    sections only: %w[all additional]
    property :id, Integer, desc: "Numerical ID of the report"
    property :origin, String, desc: "The origin of the report, e.g. 'Ansible'"
    property :metrics, Hash, desc: "A hash of report metrics and their values"
    property :host, 'Host', desc: "The host this report belongs to"
    property :status, Hash, desc: "A key => value object where key is status metric name and value is the metric count"
    property :reported_at, 'ActiveSupport::TimeWithZone', desc: "The time when the report was generated"
  end

  class Jail < Safemode::Jail
    allow :id, :origin, :metrics, :host, :status, :reported_at
  end

  def self.import(report, proxy_id = nil)
    ConfigReportImporter.import(report, proxy_id)
  end

  # puppet report status table column name
  def self.report_status_column
    "status"
  end

  # a method that save the report values (e.g. values from METRIC)
  # it is not supported to edit status values after it has been written once.
  def status=(st)
    s = case st
          when Integer
            st
          when Hash
            ConfigReportStatusCalculator.new(:counters => st).calculate
          else
            raise Foreman::Exception(N_('Unsupported report status format'))
        end
    self[:status] = s
  end

  def config_retrieval
    metrics[:time][:config_retrieval].round(2) rescue 0
  end

  def runtime
    (metrics[:time][:total] || metrics[:time].values.sum).round(2) rescue 0
  end

  # Batch size for IN-clause chunking in summarise. Prevents unbounded queries
  # when the host list is large.
  SUMMARISE_BATCH_SIZE = 1000
  private_constant :SUMMARISE_BATCH_SIZE

  # returns a hash of hosts and their recent reports metric counts which have values
  # e.g. non zero metrics.
  # first argument is time range, everything afterwards is a host list.
  def self.summarise(time = 1.day.ago, *hosts)
    list = {}
    raise ::Foreman::Exception.new(N_("invalid host list")) unless hosts
    hosts_by_id = hosts.flatten.index_by(&:id)
    # Load reports in batches to avoid an unbounded IN clause when the host
    # list is large (e.g. a full host page).
    reports_by_host = {}
    hosts_by_id.keys.each_slice(SUMMARISE_BATCH_SIZE) do |batch_ids|
      ConfigReport.where(:host_id => batch_ids).recent(time).select(:host_id, :status).each do |r|
        (reports_by_host[r.host_id] ||= []) << r
      end
    end
    hosts_by_id.each do |host_id, host|
      metrics = {}
      METRIC.each { |m| metrics[m] = 0 }
      (reports_by_host[host_id] || []).each do |r|
        metrics.each_key do |m|
          metrics[m] += r.status_of(m)
        end
      end
      list[host.name] = {:metrics => metrics, :id => host.id} if metrics.values.sum > 0
    end
    list
  end

  def summary_status
    return _("Failed")   if error?
    return _("Modified") if changes?
    _("Success")
  end

  delegate :error?, :changes?, :pending?, :status, :status_of, :to => :calculator
  # delegate all metric methods
  delegate(*METRIC, :to => :calculator)
  # delegate all metric_s (as string) methods
  delegate(*(METRIC.map { |x| "#{x}_s".to_sym }), :to => :calculator)

  def calculator
    ConfigReportStatusCalculator.new(:bit_field => self[self.class.report_status_column])
  end
end
