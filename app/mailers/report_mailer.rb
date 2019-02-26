class ReportMailer < ApplicationMailer
  def report(mail_to, filename, report_result, opts = {})
    attachments[filename] = report_result

    mail(to: mail_to, subject: opts[:subject] || _('Report result'))
  end
end
