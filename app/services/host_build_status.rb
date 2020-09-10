class HostBuildStatus
  attr_reader :host, :state, :errors
  delegate :available_template_kinds, :smart_proxies, :to => :host
  VALIDATION_TYPES = [:host, :templates, :proxies]

  def initialize(host)
    @host   = host
    @errors = {}
    @state  = true # default to true state
    VALIDATION_TYPES.each { |type| @errors[type] = [] }
  end

  def check_all_statuses
    host_status
    templates_status
    smart_proxies_status
  end

  private

  def host_status
    return if host.valid?
    host.errors.full_messages.each do |error|
      fail!(:host, error.to_s, host.to_param)
    end
  rescue => error
    fail!(:host, _('Failed to validate %{host}: %{error}') % {:host => host, :error => error.to_s}, host.to_param)
  end

  def templates_status
    fail!(:templates, _('No templates found for this host.')) if available_template_kinds.empty?

    available_template_kinds.each do |template|
      Rails.logger.info "Rendering #{template}"
      valid_template = host.render_template(template: template)
      fail!(:templates, _('Template %s is empty.') % template.name, template.to_param) if valid_template.blank?
    rescue => exception
      Foreman::Logging.exception("Review template error", exception)
      fail!(:templates, _('Failure parsing %{template}: %{error}.') % {:template => template.name, :error => exception}, template.to_param)
    end
  end

  def smart_proxies_status
    fail!(:proxies, _('No smart proxies found.')) if smart_proxies.empty?

    smart_proxies.each do |proxy|
      proxy.ping
      errors = proxy.errors.messages
      errors = errors.is_a?(Array) ? errors.to_sentence : errors
      fail!(:proxies, _('Failure deploying via smart proxy %{proxy}: %{error}.') % {:proxy => proxy, :error => errors}, proxy.to_param) if proxy.errors.any?
    rescue => error
      fail!(:proxies, _('Error connecting to %{proxy}: %{error}.') % {:proxy => proxy, :error => error}, proxy.to_param)
    end
  end

  def fail!(type, message, id = nil)
    @state = false
    @errors[type] << {:message => message, :edit_id => id}
  end
end
