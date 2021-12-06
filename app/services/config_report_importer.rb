class ConfigReportImporter < ReportImporter
  def report_name_class
    ConfigReport
  end

  def self.authorized_smart_proxy_features
    ReportImporter.authorized_smart_proxy_features
  end

  def self.register_smart_proxy_feature(feature)
    ReportImporter.register_smart_proxy_feature(feature)
  end

  def self.unregister_smart_proxy_feature(feature)
    ReportImporter.unregister_smart_proxy_feature(feature)
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
