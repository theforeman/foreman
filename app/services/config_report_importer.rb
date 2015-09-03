class ConfigReportImporter < ReportImporter
  def self.authorized_smart_proxy_features
    ['Puppet']
  end

  def report_name_class
    ConfigReport
  end

  private

  def create_report_and_logs
    super
    return report unless report.persisted?
    # we update our host record, so we won't need to lookup the report information just to display the host list / info
    host.update_attribute(:last_report, time) if host.last_report.nil? or host.last_report.utc < time
    # Store all Puppet message logs
    import_log_messages
    # Check for errors
    notify_on_report_error(:puppet_error_state)
  end
end
