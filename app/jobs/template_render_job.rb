class TemplateRenderJob < ApplicationJob
  queue_as :default

  def perform(composer_params, opts = {})
    user = User.unscoped.find(opts[:user_id])
    composer_params['gzip'] = opts[:gzip].nil? ? !!composer_params['gzip'] : opts[:gzip]
    User.as user.login do
      composer = ReportComposer.new(composer_params)
      result = composer.render
      if composer.send_mail?
        ReportMailer.report(composer.mail_to, composer.report_filename, result).deliver_now
      else
        StoredValue.write(provider_job_id, result, expire_at: Time.now + 1.day)
      end
    end
  end

  def template_id
    arguments.first['template_id'] unless arguments.first.nil?
  end

  def humanized_name
    template = template_id && ReportTemplate.unscoped.find_by(id: template_id)
    (template && (_('Render report %s') % template.name)) || _('Render report template')
  end
end
