class UnattendedController < ApplicationController
  include ::Foreman::Controller::IpFromRequestEnv
  include ::Foreman::Controller::TemplateRendering

  layout false

  # We don't require any of these methods for provisioning
  skip_before_action :require_login, :check_user_enabled, :session_expiry, :update_activity_time, :set_taxonomy, :authorize, unless: -> { preview? }

  # Allow HTTP POST methods without CSRF
  skip_before_action :verify_authenticity_token

  before_action :set_admin_user, unless: -> { preview? }
  before_action :load_host_details, only: [:host_template, :built, :failed]

  # all of our requests should be returned in text/plain
  after_action :set_content_type

  # Maximum size of built/failed request body accepted to prevent DoS (in bytes)
  MAX_BUILT_BODY = 65535

  def built
    return unless verify_found_host
    return head(:method_not_allowed) unless allowed_to_install?

    logger.info "#{controller_name}: #{@host.name} is built!"
    # Clear possible previous errors
    @host.build_errors = nil
    update_ip if Setting[:update_ip_from_built_request]
    head(@host.built ? :created : :conflict)
  end

  def failed
    return unless verify_found_host
    return head(:method_not_allowed) unless allowed_to_install?
    return if preview? || !@host.build

    logger.warn "#{controller_name}: #{@host.name} build failed!"
    @host.build_errors = request.body.read(MAX_BUILT_BODY)&.encode('utf-8', invalid: :replace, undef: :replace, replace: '_')
    body_length = @host.build_errors.try(:size) || 0
    @host.build_errors += "\n\nOutput trimmed\n" if body_length >= MAX_BUILT_BODY
    logger.warn { "Log lines from the OS installer:\n#{@host.build_errors}" }
    head(@host.built ? :created : :conflict)
  end

  def hostgroup_template
    return head(:not_found) unless (params.has_key?("id") && params.has_key?(:hostgroup))

    template = ProvisioningTemplate.find_by_name(params['id'].to_s)
    @host = Hostgroup.find_by_title(params['hostgroup'].to_s)
    return head(:not_found) unless template && @host

    safe_render(template)
  end

  # Generate an action for each template kind
  # i.e. /unattended/provision will render the provisioning template for the requesting host
  def host_template
    kind = params[:kind]
    return head(:not_found) unless kind.present?

    return if render_ipxe_template

    return unless verify_found_host
    return head(:method_not_allowed) unless allowed_to_install?
    (handle_realm || return) if kind == 'provision'

    render_provisioning_template(kind)
  end

  protected

  def require_ssl?
    preview? ? super : unattended_ssl?
  end

  private

  def preview?
    params.key?(:spoof) || params.key?(:hostname)
  end

  def render_error(message, options)
    if ipxe_request?
      render_ipxe_message(message: message, status: options[:status] || :not_found)
    else
      super
    end
  end

  def render_intermediate_template
    ipxe_template_kind = TemplateKind.find_by(name: 'iPXE')
    name = Setting[:intermediate_ipxe_script]
    template = ProvisioningTemplate.find_by(name: name, template_kind: ipxe_template_kind)

    if template
      safe_render(template)
    else
      render_ipxe_message(message: _("iPXE intermediate script '%s' not found") % name)
    end
  end

  def render_default_global_template
    name = ProvisioningTemplate.global_template_name_for('iPXE')
    template = ProvisioningTemplate.find_global_default_template(name, 'iPXE')

    return safe_render(template) if template

    render_ipxe_message(message: _("Global iPXE template '%s' not found") % name)
  end

  def render_local_boot_template
    return unless verify_found_host

    ipxe_template_kind = TemplateKind.find_by(name: 'iPXE')
    name = @host.local_boot_template_name(:iPXE) || ProvisioningTemplate.local_boot_name(:iPXE)
    template = ProvisioningTemplate.find_by(name: name, template_kind: ipxe_template_kind)

    return safe_render(template) if template

    render_ipxe_message(message: _("iPXE default local boot template '%s' not found") % name)
  end

  def render_provisioning_template(type)
    # Compatibility with older URLs
    type = 'iPXE' if type == 'gPXE'

    template = @host.provisioning_template(kind: type)

    render_template(template: template, type: type)
  end

  # Returns true if a template was rendered, false otherwise
  def render_ipxe_template
    return false unless ipxe_request?

    if @host.nil? && params[:bootstrap]
      render_intermediate_template
      return true
    end

    if @host.nil?
      render_default_global_template
      return true
    end

    unless @host.try(:build?)
      render_local_boot_template
      return true
    end

    false
  end

  def load_host_details
    query_params = params
    query_params[:ip] = ip_from_request_env
    query_params[:mac_list] = Foreman::UnattendedInstallation::MacListExtractor.new.extract_from_env(request.env, params: params)
    query_params[:built] = ['built', 'failed'].include? action_name

    @host = Foreman::UnattendedInstallation::HostFinder.new(query_params: query_params).search
  end

  def verify_found_host
    host_verifier = Foreman::UnattendedInstallation::HostVerifier.new(@host, request_ip: request.env['REMOTE_ADDR'],
                                                                             for_host_template: (action_name == 'host_template'))

    if host_verifier.valid?
      logger.debug "Found #{@host}"
      return true
    end

    error = host_verifier.errors.first
    render_error(error[:message], { :status => error[:type] }.merge(error[:params]))
    false
  end

  def allowed_to_install?
    @host.build? || spoof || Setting[:access_unattended_without_build]
  end

  # Reset realm OTP. This is run as a before_action for provisioning templates.
  def handle_realm
    # We don't do anything if we are in spoof mode.
    return true if spoof

    # This should terminate the before_action and the action. We return a HTTP
    # error so the installer knows something is wrong. This is tested with
    # Anaconda, but maybe Suninstall will choke on it.
    unless @host.handle_realm
      render(:plain => _("Failed to get a new realm OTP. Terminating the build!"), :status => :internal_server_error)
      return false
    end

    true
  end

  def set_content_type
    response.headers['Content-Type'] = 'text/plain'
  end

  # This method updates the IP held by Foreman from the incoming request.
  # Useful on unmanaged DHCP systems, with token-based installs where Foreman
  # doesn't know the IP in advance (and has been given a fake one just to make
  # the form save)
  def update_ip
    ip = ip_from_request_env
    logger.debug "Built notice from #{ip}, current host ip is #{@host.ip}, updating" if @host.ip != ip

    # @host has been changed even if the save fails, so we have to change it back
    old_ip = @host.ip
    @host.ip = old_ip unless @host.update({'ip' => ip})
  end

  def ipxe_request?
    %w[iPXE gPXE].include?(params[:kind])
  end

  def render_ipxe_message(message: _('An error occurred.'), status: :not_found)
    render(plain: Foreman::Ipxe::MessageRenderer.new(message: message).to_s, status: status, content_type: 'text/plain')
  end

  def spoof
    @spoof ||= @host.present? && (params.key?(:spoof) || params.key?(:hostname))
  end
end
