class ReportImporter
  include Foreman::TelemetryHelper

  delegate :logger, :to => :Rails
  attr_reader :report, :report_scanners

  # When writing your own Report importer, provide feature(s) of authorized Smart Proxies
  def self.authorized_smart_proxy_features
    @authorized_smart_proxy_features ||= []
  end

  def self.register_smart_proxy_feature(feature)
    @authorized_smart_proxy_features = (authorized_smart_proxy_features + [feature]).uniq
  end

  def self.unregister_smart_proxy_feature(feature)
    @authorized_smart_proxy_features -= [feature]
  end

  def self.import(raw, proxy_id = nil)
    importer = new(raw, proxy_id)
    importer.import
    importer.report
  end

  # to be overriden in children
  def report_name_class
    raise NotImplementedError, "#{__method__} not implemented for this report importer"
  end

  def initialize(raw, proxy_id = nil)
    raise ::Foreman::Exception.new(_('Invalid report')) unless raw.is_a?(Hash) || raw.is_a?(ActionController::Parameters)
    @raw      = raw
    @proxy_id = proxy_id
  end

  def import
    logger.debug { "Processing report: #{raw.inspect}" }
    telemetry = {}
    telemetry_duration_histogram(:report_importer_create, :ms, {type: self.class.name}, telemetry) do
      create_report_and_logs
    end
    if report.persisted?
      telemetry_duration_histogram(:report_importer_refresh, :ms, {type: self.class.name}, telemetry) do
        host.refresh_statuses(statuses_for_refresh)
      end
      create = telemetry[:report_importer_create].try(:round, 1)
      refresh = telemetry[:report_importer_refresh].try(:round, 1)
      logger.info("Imported report for #{name} in #{create} ms, status refreshed in #{refresh} ms")
    end
  end

  def add_reporter_specific_data
    logger.info "Scanning report with: #{report_scanners.join(', ')}"
    report_scanners.each do |scanner|
      if scanner.respond_to?(:identify_origin)
        if (origin = scanner.identify_origin(raw))
          report.origin = origin
          scanner.add_reporter_data(report, raw)
          break
        end
      else
        Foreman::Deprecation.deprecation_warning('2.4', "report_scanners need to implement identify_origin and add_reporter_data methods, but #{scanner} does not.")
        break if scanner.scan(report, logs)
      end
    end
    logger.debug { "Changes after reporter specific data added: #{report.changes.inspect}" }
  end

  private

  attr_reader :raw, :proxy_id

  def name
    @name ||= raw['host']
  end

  def host
    hostname = name.downcase
    @host ||= Host::Base.find_by_certname(hostname) ||
      Host::Base.find_by_name(hostname) ||
      Host::Managed.new(:name => hostname)
  end

  def time
    @time ||= Time.parse(raw['reported_at']).utc
  end

  def logs
    raw['logs'] || []
  end

  def import_log_messages
    return if logs.blank?
    id_messages = []
    db_messages = []
    id_sources = []
    db_sources = []
    db_logs = []
    logs.each do |log|
      msg = log['log']['messages']['message']
      src = log['log']['sources']['source']

      msg_id = Message.where(value: msg).pluck(:id).first
      if msg_id
        id_messages << msg_id
      else
        id_messages << nil
        db_messages << {value: msg}
      end

      src_id = Source.where(value: src).pluck(:id).first
      if src_id
        id_sources << src_id
      else
        id_sources << nil
        db_sources << {value: src}
      end
    end
    new_messages = Message.insert_all(db_messages, returning: %w[id]).rows.flatten
    new_sources = Source.insert_all(db_sources, returning: %w[id]).rows.flatten
    current_msg_id = 0
    current_msg_new_id = 0
    current_src_id = 0
    current_src_new_id = 0
    logs.each do |log|
      level = log['log']['level']
      level_id = Report::LOG_LEVELS.index(level)
      raise(::Foreman::Exception.new(N_("Invalid log level: %s", level))) unless level_id

      msg_id = id_messages[current_msg_id]
      unless msg_id
        msg_id = new_messages[current_msg_new_id]
        current_msg_new_id += 1
      end

      src_id = id_sources[current_src_id]
      unless src_id
        src_id = new_sources[current_src_new_id]
        current_src_new_id += 1
      end

      db_logs << {:message_id => msg_id, :source_id => src_id, :report_id => report.id, :level_id => level_id}
      current_msg_id += 1
      current_src_id += 1
    end
    Log.insert_all(db_logs)
  end

  def report_status
    raise NotImplementedError
  end

  def statuses_for_refresh
    HostStatus.status_registry
  end

  def notify_on_report_error(mail_error_state)
    if report.error?
      # found a report with errors
      # notify via email IF enabled is set to true

      if host.disabled?
        logger.warn "#{name} is disabled - skipping alert"
        return
      end

      owners = host.owner.present? ? host.owner.recipients_for(:config_error_state) : []
      users = ConfigManagementError.all_hosts.flat_map(&:users)
      users = users.select do |user|
        User.as user do
          Host.authorized_as(user, :view_hosts).find(host.id).present?
        rescue ActiveRecord::RecordNotFound
          nil
        end
      end
      owners.concat users
      if owners.present?
        logger.debug { "sending alert to #{owners.map(&:login).join(',')}" }
        MailNotification[mail_error_state].deliver(report, :users => owners.uniq)
      else
        logger.debug { "no owner or recipients for alert on #{name}" }
      end
    end
  end

  def create_report_and_logs
    if host.new_record? && !Setting[:create_new_host_when_report_is_uploaded]
      logger.info("skipping report for #{name} as its an unknown host and create_new_host_when_report_is_uploaded setting is disabled")
      @report = report_name_class.new
      return @report
    end

    # we save the host without validation for two reasons:
    # 1. It might be auto imported, therefore might not be valid (e.g. missing partition table etc)
    # 2. We want this to be fast and light on the db.
    # at this point, the report is important, not the host
    host.save(:validate => false)

    status = report_status
    # and save our report
    @report = report_name_class.new(:host => host, :reported_at => time, :status => status, :metrics => raw['metrics'])

    # Run report scanner
    add_reporter_specific_data

    @report.save
    @report
  end

  def report_scanners
    Foreman::Plugin.report_scanner_registry.report_scanners
  end
end
