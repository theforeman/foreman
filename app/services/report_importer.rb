class ReportImporter
  delegate :logger, :to => :Rails
  attr_reader :report

  # When writing your own Report importer, provide feature(s) of authorized Smart Proxies
  def self.authorized_smart_proxy_features
    @authorized_smart_proxy_features ||= []
  end

  def self.register_smart_proxy_feature(feature)
    @authorized_smart_proxy_features = (authorized_smart_proxy_features + [ feature ]).uniq
  end

  def self.unregister_smart_proxy_feature(feature)
    @authorized_smart_proxy_features -= [ feature ]
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
    start_time = Time.now
    logger.debug { "Processing report: #{raw.inspect}" }
    create_report_and_logs
    if report.persisted?
      imported_time = Time.now
      host.refresh_statuses(statuses_for_refresh)
      refreshed_time = Time.now
      logger.info("Imported report for #{name} in #{(imported_time - start_time).round(2)} seconds, status refreshed in #{(refreshed_time - imported_time).round(2)} seconds")
    end
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

      owners = host.owner.present? ? host.owner.recipients_for(:puppet_error_state) : []
      users = PuppetError.all_hosts.flat_map(&:users)
      users.select { |user| Host.authorized_as(user, :view_hosts).find(host.id).present? }
      owners.concat users
      if owners.present?
        logger.debug "sending alert to #{owners.map(&:login).join(',')}"
        MailNotification[mail_error_state].deliver(report, :users => owners.uniq)
      else
        logger.debug "no owner or recipients for alert on #{name}"
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
    @report.save
    @report
  end
end
