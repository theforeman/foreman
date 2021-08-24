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
      if (host && !host.enabled?) || no_reports? || out_of_sync_disabled?
        false
      else
        !reported_at.nil? && reported_at < (Time.now.utc - expected_report_interval)
      end
    end

    def expected_report_interval
      (reported_origin_interval || default_report_interval).minutes
    end

    def reported_origin_interval
      if last_report.origin
        if host.params.has_key? "#{last_report.origin.downcase}_interval"
          interval = host.params["#{last_report.origin.downcase}_interval"]
        else
          interval = Setting[:"#{last_report.origin.downcase}_interval"]
        end
        interval.to_i
      end
    end

    def no_reports?
      host && last_report.nil?
    end

    def to_global(options = {})
      handle_options(options)

      if error?
        # error
        HostStatus::Global::ERROR
      elsif out_of_sync?
        # out of sync
        HostStatus::Global::WARN
      elsif no_reports? && (host.configuration? || Setting[:always_show_configuration_status])
        # no reports and configuration is set
        HostStatus::Global::WARN
      else
        # active, pending, no changes, no reports (or host not setup for configuration)
        HostStatus::Global::OK
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

    def relevant?(options = {})
      handle_options(options)

      host.configuration? || last_report.present? || Setting[:always_show_configuration_status]
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

    def status_link
      return nil if last_report.nil?
      return nil unless User.current.can?(:view_config_reports, last_report)

      last_report && Rails.application.routes.url_helpers.config_report_path(last_report)
    end

    private

    def handle_options(options)
      if options.has_key?(:last_reports) && !options[:last_reports].nil?
        cached_report = options[:last_reports].find { |r| r.host_id == host_id }
        self.last_report = cached_report
      end
    end

    def update_timestamp
      self.reported_at = last_report.try(:reported_at) || Time.now.utc
    end

    def calculator
      ConfigReportStatusCalculator.new(:bit_field => status)
    end

    def default_report_interval
      Setting[:outofsync_interval]
    end

    def out_of_sync_disabled?
      if last_report.origin
        Setting[:"#{last_report.origin.downcase}_out_of_sync_disabled"]
      else
        false
      end
    end
  end
end

HostStatus.status_registry.add(HostStatus::ConfigurationStatus)
