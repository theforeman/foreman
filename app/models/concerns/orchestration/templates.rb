module Orchestration::Templates
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :queue_render_checks
  end

  def queue_render_checks
    return if skip_orchestration?
    return unless managed?
    return unless template_to_render

    logger.debug "Scheduling render checks of template for #{self}"

    queue.create name: _("Check renderability of template '%{name}'.") % { name: template_to_render.name },
      priority: 1, action: [self, :set_renderability]
  end

  def set_renderability
    template_to_render.render(host: self)
    true
  rescue => e
    Foreman::Logging.exception("Error while rendering '#{template_to_render.name}' template", e)
    failure _("Failed to render template '%{t}', error: %{e}") % { t: template_to_render.name, e: e }
  end

  def del_renderability
    # No-op, we don't need to delete the rendered template
  end

  private

  def template_to_render
    kind = case provision_method
      when 'build'
        'provision'
      when 'image'
        template_kinds('image').first&.name
           end

    @template_to_render ||= provisioning_template(kind: kind)
  end
end
