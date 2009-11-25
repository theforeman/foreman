class Report < ActiveRecord::Base
  belongs_to :host
  serialize :log, Puppet::Transaction::Report
  validates_presence_of :log, :host_id, :reported_at, :status
  validates_uniqueness_of :reported_at, :scope => :host_id

  def to_label
    "#{host.name} / #{reported_at.to_s}"
  end

  def failed
    validate_meteric("resources",:failed)
  end

  def failed_restarts
    validate_meteric("resources", :failed_restarts)
  end

  def skipped
    validate_meteric("resources", :skipped)
  end

  def error?
    status > 0
  end

  def changes?
    t = validate_meteric("changes", :total)
    t > 0 if t
  end

  def config_retrival
    t = validate_meteric("time", :config_retrieval)
    t.round_with_precision(2) if t
  end

  def runtime
    t = validate_meteric("time", :total)
    t.round_with_precision(2) if t
  end

  #imports a yaml report into database
  def self.import(yaml)
    report = YAML.load(yaml)
    raise "Invalid report" unless report.is_a?(Puppet::Transaction::Report)
    logger.info "processing report for #{report.host}"
    begin
      host = Host.find_or_create_by_name report.host
      report_status = host.puppet_status = report_status(report)
      host.last_report = report.time.utc if host.last_report.nil? or host.last_report.utc < report.time.utc

      # we save the host without validation for two reasons:
      # 1. it might be auto imported, therefore might not be valid (e.g. missing partition table etc)
      # 2. we want this to be fast and light on the db.
      # at this point, the report is important, not as much of the host
      host.save_with_validation(perform_validation = false)

      self.create! :host => host, :reported_at => report.time.utc, :log => report, :status => report_status
    rescue Exception => e
      logger.warn "failed to process report for #{report.host} due to:#{e}"
    end
  end

  def self.summarise(message, type, hosts)
    hosts.each do |host|
      failed          = (host.puppet_status & 0x00000fff)
      skipped         = (host.puppet_status & 0x00fff000) >> 12
      failed_restarts = (host.puppet_status & 0x3f000000) >> 24
      no_report       = (host.puppet_status & 0x40000000) >> 30
      message << "%-30s %9d %9d %9d %9d" % [host.name, failed, failed_restarts, skipped, no_report]
      type[:failed]          +=1 if failed          > 0
      type[:failed_restarts] +=1 if failed_restarts > 0
      type[:skipped]         +=1 if skipped         > 0
      type[:no_report]       +=1 if no_report
    end
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
    cond = "reported_at < \'#{(Time.now.utc - timerange).to_formatted_s(:db)}\'"
    cond += " and status = #{status}" unless status.nil?
    # delete the reports
    count = Report.delete_all(cond)
    logger.info Time.now.to_s + ": Expired #{count} Reports"
    return count
  end

  def self.count_puppet_runs(interval = 5)
    counter = []
    now=Time.now.utc
    (1..(30 / interval)).each do |i|
      ago = now - interval.minutes
      counter << Report.count(:all, :conditions => {:reported_at => ago..(now-1.second)})
      now = ago
    end
    counter
  end




  protected

  # process the metrics
  # 0 is a good report, anything else requires attention
  def self.report_status report
      status = 0
      raise "Invalid report: can't find metrics information for #{report.host} at #{report.id}" if report.metrics.nil?
      resources = report.metrics["resources"]
      # check if the report actually contain anything interesting
      if resources[:failed] + resources[:skipped] + resources[:failed_restarts] + report.metrics["changes"][:total] > 0
        status  = resources[:failed] if resources[:failed] > 0
        # We only capture skipped errors when there are associated log entries.
        # Sometimes there are skipped entries but no errors in the messages file,
        # This can happen when having notice, alias messages etc
        status |= resources[:skipped] if resources[:skipped] > 0 and report.logs.size >0

        status |= resources[:failed_restarts] << 24 if resources[:failed_restarts] > 0
      end

      return status
  end

  protected

  def validate_meteric (type, name)
    begin
      log.metrics[type][name]
    rescue
      nil
    end
  end

end
