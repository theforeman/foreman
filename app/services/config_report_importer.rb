class ConfigReportImporter < ReportImporter
  def self.authorized_smart_proxy_features
    @authorized_smart_proxy_features ||= super + ['Puppet', 'Ansible']
  end

  def report_name_class
    ConfigReport
  end

  private

  def create_report_and_logs
    super
    return report unless report.persisted?
    # we update our host record, so we won't need to lookup the report information just to display the host list / info
    host.update_attribute(:last_report, time) if host.last_report.nil? || host.last_report.utc < time

    # Store all Puppet message logs
    import_log_messages

    # Check for errors
    notify_on_report_error(:config_error_state)

    # Report metric counts via telemetry
    ConfigReportStatusCalculator.new(:bit_field => report_status).status.each do |metric, count|
      telemetry_increment_counter(:config_report_metric_count, count, metric: metric) if count > 0
    end
  end

  def report_status
    ConfigReportStatusCalculator.new(:counters => raw['status']).calculate
  end

  def statuses_for_refresh
    [HostStatus.find_status_by_humanized_name("configuration")]
  end
end
