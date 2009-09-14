class Report < ActiveRecord::Base
  belongs_to :host
  serialize :log, Puppet::Transaction::Report
  validates_presence_of :log, :host_id, :reported_at
  validates_uniqueness_of :reported_at

  def failed
    log.metrics["resources"][:failed]
  end

  def failed_restarts
    log.metrics["resources"][:failed_restarts]
  end

  def skipped
    log.metrics["resources"][:skipped]
  end

  #imports a yaml report into database
  def self.import(yaml)
    report = YAML.load(yaml)
    raise "invalid report" unless report.is_a?(Puppet::Transaction::Report)

    logger.info "processing report for #{report.name}"
    begin
      if (host = Host.find_by_name report.host)
        host.last_report = report.time if host.last_report.nil? or host.last_report < report.time

        resources = report.metrics["resources"]
        # check if the report actually contain anything interesting
        if resources[:failed] + resources[:skipped] + resources[:failed_restarts] + report.metrics["changes"][:total] > 0
          host.puppet_status  = 0
          host.puppet_status  = resources[:failed] if resources[:failed] > 0
          # We only capture skipped errors when there are associated log entries.
          # Sometimes there are skipped entries but no errors in the messages file.
          # I do not know what this means.
          host.puppet_status |= resources[:skipped] << 12 if resources[:skipped] > 0 and report.logs.size > 0
          host.puppet_status |= resources[:failed_restarts] << 24 if resources[:failed_restarts] > 0

          Report.create :log => report, :host => host, :reported_at => report.time
        end
        # we save the host without validation for two reasons:
        # 1. it might be auto imported, therefore might not be valid (e.g. missing partition table etc)
        # 2. we want this to be fast and light on the db.
        # at this point, the report is important, not as much of the host
        host.save_with_validation(perform_validation = false)
      else
        logger.info "Found report for #{report.name} which is not in out DB, interesting...."
        return false
      end

    rescue Exception => e
      logger.warn "failed to process report for #{report.name} due to:#{e}"
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
      type[:no_report]       +=1 if no_report       > 0
    end
  end

  # We do not keep more than 24 hours of history in the database
  def self.expire_reports
    expired = Report.find(:all, :conditions => ["reported_at < ?",(Time.now.utc - 24.hours)])
    # We only expire reports if there is at least one newer report.
    # This way, there is always a report to look at if the host shows an error. Even if there have been no reports for more than a day
    expired = expired.sort.map{|report| report.host.reports.size > 1}
    logger.info Time.now.to_s + ": Expiring #{expired.size} reports"
    expired.each{|report| report.destroy}
  end

end
