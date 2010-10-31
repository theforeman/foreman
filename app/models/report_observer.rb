class ReportObserver < ActiveRecord::Observer
  def after_save report
    if report.error?
      # found a report with errors
      # notify via email IF enabled is set to true
      if report.host.disabled?
        report.logger.warn "#{report.host} is disabled - skipping."
        return
      end
      HostMailer.deliver_error_state(report) if SETTINGS[:failed_report_email_notification]
      # add here more actions - e.g. snmp alert etc
    end
  rescue => e
    report.logger.warn "failed to send failure email notification: #{e}" if report.logger
  end
end
