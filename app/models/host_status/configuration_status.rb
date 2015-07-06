module HostStatus
  class ConfigurationStatus < Status
    delegate :error?, :changes?, :pending?, :to => :calculator
    delegate(*ConfigReport::METRIC, :to => :calculator)

    def last_report
      self.last_report = host.last_report_object unless @last_report_set
      @last_report
    end

    def last_report=(report)
      @last_report_set = true
      @last_report = report
    end

    def out_of_sync?
      if (host && !host.enabled?) || no_reports?
        false
      else
        !reported_at.nil? && reported_at < (Time.now - (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes)
      end
    end

    def no_reports?
      host && last_report.nil?
    end

    def to_global(options = {})
      handle_options(options)

      if error?
        # error
        return HostStatus::Global::ERROR
      elsif out_of_sync?
        # out of sync
        return HostStatus::Global::WARN
      elsif no_reports? && host.configuration?
        # no reports and configuration is set
        return HostStatus::Global::WARN
      else
        # active, pending, no changes, no reports (or host not setup for configuration)
        return HostStatus::Global::OK
      end
    end

    def self.status_name
      N_("Configuration")
    end

    def to_label(options = {})
      handle_options(options)

      if host && !host.enabled
        N_("Alerts disabled")
      elsif no_reports?
        N_("No reports")
      elsif error?
        N_("Error")
      elsif out_of_sync?
        N_("Out of sync")
      elsif changes?
        N_("Active")
      elsif pending?
        N_("Pending")
      else
        N_("No changes")
      end
    end

    def to_status(options = {})
      handle_options(options)

      if host && last_report.present?
        last_report.read_attribute(:status)
      else
        0
      end
    end

    def self.is(config_status)
      "((host_status.status >> #{bit_mask(config_status)}) != 0)"
    end

    def self.is_not(config_status)
      "((host_status.status >> #{bit_mask(config_status)}) = 0)"
    end

    def self.bit_mask(config_status)
      "#{ConfigReport::BIT_NUM * ConfigReport::METRIC.index(config_status)} & #{ConfigReport::MAX}"
    end

    private

    def handle_options(options)
      if options.has_key?(:last_reports) && !options[:last_reports].nil?
        cached_report = options[:last_reports].find { |r| r.host_id == self.host_id }
        self.last_report = cached_report
      end
    end

    def update_timestamp
      self.reported_at = last_report.try(:reported_at) || Time.now
    end

    def calculator
      ConfigReportStatusCalculator.new(:bit_field => status)
    end
  end
end

HostStatus.status_registry.add(HostStatus::ConfigurationStatus)
