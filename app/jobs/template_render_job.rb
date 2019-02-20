class TemplateRenderJob < ApplicationJob
  queue_as :default

  def perform(composer_params, opts = {})
    user = User.unscoped.find(opts[:user_id])
    User.as user.login do
      composer = ReportComposer.new(composer_params.merge(gzip: opts[:gzip]))
      composer.render_to_store(provider_job_id)
    end
  end
end
