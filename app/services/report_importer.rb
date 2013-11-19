class ReportImporter
  delegate :logger, :to => :Rails
  attr_reader :report

  def self.import(raw, proxy_id = nil)
    importer = new(raw, proxy_id)
    importer.import
    importer.report
  end

  def initialize(raw, proxy_id = nil)
    raise ::Foreman::Exception.new(_('Invalid report')) unless raw.is_a?(Hash)
    @raw      = raw
    @proxy_id = proxy_id
  end

  def import
    start_time = Time.now
    logger.info "processing report for #{name}"
    logger.debug { "Report: #{raw.inspect}" }

    if system.new_record? && !Setting[:create_new_system_when_report_is_uploaded]
      logger.info("skipping report for #{name} as its an unknown system and create_new_system_when_report_is_uploaded setting is disabled")
      return Report.new
    end

    # convert report status to bit field
    st                   = ReportStatusCalculator.new(:counters => raw['status']).calculate

    # we update our system record, so we won't need to lookup the report information just to display the system list / info
    system.last_report     = time if system.last_report.nil? or system.last_report.utc < time
    # we save the report bit status value in our system too.
    system.puppet_status   = st

    # if proxy authentication is enabled and we have no puppet proxy set, use it.
    system.puppet_proxy_id ||= proxy_id

    # we save the system without validation for two reasons:
    # 1. It might be auto imported, therefore might not be valid (e.g. missing partition table etc)
    # 2. We want this to be fast and light on the db.
    # at this point, the report is important, not the system
    system.save(:validate => false)

    # and save our report
    @report = Report.new(:system => system, :reported_at => time, :status => st, :metrics => raw['metrics'])
    return report unless report.save
    # Store all Puppet message logs
    import_log_messages
    # Check for errors
    inspect_report
    logger.info("Imported report for #{name} in #{(Time.now - start_time).round(2)} seconds")
  end

  private
  attr_reader :raw, :proxy_id

  def name
    @name ||= raw['system']
  end

  def system
    @system ||= System::Base.find_by_certname(name) ||
      System::Base.find_by_name(name) ||
      System::Managed.new(:name => name)
  end

  def time
    @time ||= Time.parse(raw['reported_at']).utc
  end

  def logs
    raw['logs'] || []
  end

  def import_log_messages
    logs.each do |log|
      # Parse the API format
      level = log['log']['level']
      msg   = log['log']['messages']['message']
      src   = log['log']['sources']['source']

      message = Message.find_or_create msg
      source  = Source.find_or_create src

      # Symbols get turned into strings via the JSON API, so convert back here if it matches
      # and expected log level. Log objects can't be created without one, so raise if not
      raise(::Foreman::Exception.new(N_("Invalid log level: %s", level))) unless Report::LOG_LEVELS.include?(level)

      Log.create(:message_id => message.id, :source_id => source.id, :report => report, :level => level.to_sym)
    end
  end

  def inspect_report
    if report.error?
      # found a report with errors
      # notify via email IF enabled is set to true
      logger.warn "#{name} is disabled - skipping." and return if system.disabled?

      logger.debug 'error detected, checking if we need to send an email alert'
      SystemMailer.error_state(report).deliver if Setting[:failed_report_email_notification]
      # add here more actions - e.g. snmp alert etc
    end
  rescue => e
    logger.warn "failed to send failure email notification: #{e}"
    logger.debug e.backtrace
  end
end