class ReportMailer < ApplicationMailer
  def report(composer_params, report_result, opts = {})
    @composer = ReportComposer.new(composer_params)
    @start, @end = opts[:start], opts[:end]
    attachments[@composer.report_filename] = report_result

    mail(to: @composer.mail_to, subject: opts[:subject] || _('Result of report %s') % @composer.template&.name.to_s)
  end
end
