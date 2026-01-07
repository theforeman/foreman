module Orchestration::Templates
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :queue_render_checks
  end

  def queue_render_checks
    # Skip if the host class is not supported
    # (for example Host::Discovered from foreman_discovery)
    return unless instance_of? Host::Managed
    return if skip_orchestration?
    return unless managed?
    return unless template

    logger.debug "Scheduling render checks of template for #{self}"

    queue.create name: _("Check renderability of template '%{name}'.") % { name: template.name },
      priority: 1, action: [self, :set_renderability]
  end

  def set_renderability
    template.render(host: self)
    true
  rescue => e
    Foreman::Logging.exception("Error while rendering '#{template.name}' template", e)
    failure _("Failed to render template '%{t}', error: %{e}") % { t: template.name, e: e }
  end

  def del_renderability
    # No-op, we don't need to delete the rendered template
  end

  private

  def template
    @template ||= provisioning_template(kind: kind)
  end

  def kind
    case provision_method
    when 'build'
      'provision'
    when 'image'
      template_kinds('image').first&.name
    end
  end
end
