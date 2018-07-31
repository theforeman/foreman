class UnattendedController < ApplicationController
  layout false

  # We dont require any of these methods for provisioning
  skip_before_action :require_login, :session_expiry, :update_activity_time, :set_taxonomy, :authorize, :unless => Proc.new { preview? }

  # Allow HTTP POST methods without CSRF
  skip_before_action :verify_authenticity_token

  before_action :set_admin_user, :unless => Proc.new { preview? }
  # We want to find out our requesting host
  before_action :get_host_details, :except => [:hostgroup_template, :built, :failed]
  before_action :get_built_host_details, :only => [:built, :failed]
  before_action :allowed_to_install?, :except => :hostgroup_template
  before_action :handle_realm, :if => Proc.new { params[:kind] == 'provision' }
  # all of our requests should be returned in text/plain
  after_action :set_content_type

  # maximum size of built/failed request body accepted to prevent DoS (in bytes)
  MAX_BUILT_BODY = 65535

  def built
    logger.info "#{controller_name}: #{@host.name} is built!"
    # clear possible previous errors
    @host.build_errors = nil
    update_ip if Setting[:update_ip_from_built_request]
    head(@host.built ? :created : :conflict)
  end

  def failed
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
    return head(:not_found) unless params[:kind].present?
    render_template params[:kind]
  end

  protected

  def require_ssl?
    return super if params.key?(:spoof) || params.key?(:hostname)
    false
  end

  private

  def preview?
    params.key?(:spoof) || params.key?(:hostname)
  end

  def render_custom_error(status, error_message, params)
    logger.error error_message % params
    # add a comment character (works with Red Hat and Debian systems) to avoid parsing errors
    render(:plain => '# ' + _(error_message) % params, :status => status, :content_type => 'text/plain')
  end

  def render_template(type)
    # Compatibility with older URLs
    type = 'iPXE' if type == 'gPXE'

    template = @host.provisioning_template({ :kind => type })
    if template
      safe_render(template)
    else
      error_message = N_("unable to find %{type} template for %{host} running %{os}")
      render_custom_error(:not_found, error_message, {:type => type, :host => @host.name, :os => @host.operatingsystem})
    end
  end

  # lookup for a host based on the ip address and if possible by a mac address(as sent by anaconda)
  # if the host was found than its record will be in @host
  # if the host doesn't exists, it will return 404 and the requested method will not be reached.
  def get_host_details
    @host = find_host_by_spoof || find_host_by_token
    @host ||= find_host_by_ip_or_mac unless token_from_params.present?
    verify_valid_host_token
    verify_found_host
  end

  def get_built_host_details
    @host = find_host_by_spoof || find_built_host_by_token
    @host ||= find_host_by_ip_or_mac unless token_from_params.present?
    verify_found_host
  end

  def verify_valid_host_token
    return unless @host&.token_expired?
    render_custom_error(
      :precondition_failed,
      N_('%{controller}: provisioning token for host %{host} expired'),
      { :controller => controller_name, :host => @host.name }
    )
  end

  def verify_found_host
    logger.debug "Found #{@host}" unless host_not_found?(@host) || host_os_is_missing?(@host) || host_os_family_is_missing?(@host)
  end

  def value_missing?(value, error_message, error_type, custom_error_parameters = {})
    return false if value
    render_custom_error(error_type, error_message, custom_error_parameters)
    true
  end

  def host_not_found?(a_host)
    value_missing?(a_host, N_("%{controller}: unable to find a host that matches the request from %{addr}"),
                        :not_found, :controller => controller_name, :addr => request.env['REMOTE_ADDR'])
  end

  def host_os_is_missing?(a_host)
    value_missing?(a_host.operatingsystem, N_("%{controller}: %{host}'s operating system is missing"),
                        :conflict, :controller => controller_name, :host => a_host.name)
  end

  def host_os_family_is_missing?(a_host)
    value_missing?(a_host.operatingsystem.family, N_("%{controller}: %{host}'s operating system %{os} has no OS family"),
                   :conflict, :controller => controller_name, :host => a_host.name, :os => a_host.operatingsystem.fullname)
  end

  def find_host_by_spoof
    host = Host.authorized('view_hosts').joins(:primary_interface).where("#{Nic::Base.table_name}.ip" => params['spoof']).first if params['spoof'].present?
    host ||= Host.authorized('view_hosts').find_by_name(params['hostname']) if params['hostname'].present?
    @spoof = host.present?
    host
  end

  def find_host_by_token
    token = token_from_params
    return nil if token.nil?
    Host.for_token(token).first
  end

  def find_built_host_by_token
    token = token_from_params
    return nil if token.nil?
    Host.for_token_when_built(token).first
  end

  def token_from_params
    token = params[:token]
    return nil if token.blank?
    # Quirk: ZTP requires the .slax suffix
    if (result = token.match(/^([a-z0-9-]+)(.slax)$/i))
      return result[1]
    end
    token
  end

  def find_host_by_ip_or_mac
    # try to find host based on our client ip address
    ip = ip_from_request_env

    # in case we got back multiple ips (see #1619)
    ip = ip.split(',').first

    # search for a mac address in any of the RHN provisioning headers
    # this section is kickstart only relevant
    mac_list = []
    if request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].present?
      begin
        request.env.keys.each do |header|
          mac_list << request.env[header].split[1].strip.downcase if header =~ /^HTTP_X_RHN_PROVISIONING_MAC_/
        end
      rescue => e
        Foreman::Logging.exception("unknown RHN_PROVISIONING header", e)
        mac_list = []
      end
    end

    if params.key?(:mac)
      mac_list << params[:mac].strip.downcase
    end

    # we try to match first based on the MAC, falling back to the IP
    candidates = Host.joins(:provision_interface).where(mac_list.empty? ? {:nics => {:ip => ip}} : ["lower(nics.mac) IN (?)", mac_list]).order(:created_at)
    logger.warn("Multiple hosts found with #{ip} or #{mac_list}, picking up the most recent") if candidates.count > 1
    host = candidates.last
    # host is readonly because of association so we reload it if we find it
    host ? Host.find(host.id) : nil
  end

  def allowed_to_install?
    (@host.build || @spoof || Setting[:access_unattended_without_build]) ? true : head(:method_not_allowed)
  end

  # Reset realm OTP. This is run as a before_action for provisioning templates.
  def handle_realm
    # We don't do anything if we are in spoof mode.
    return true if @spoof

    # This should terminate the before_action and the action. We return a HTTP
    # error so the installer knows something is wrong. This is tested with
    # Anaconda, but maybe Suninstall will choke on it.
    render(:plain => _("Failed to get a new realm OTP. Terminating the build!"), :status => :internal_server_error) unless @host.handle_realm
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

  def ip_from_request_env
    ip = request.env['REMOTE_ADDR']

    # check if someone is asking on behalf of another system (load balance etc)
    if request.env['HTTP_X_FORWARDED_FOR'].present? && (ip =~ Regexp.new(Setting[:remote_addr]))
      ip = request.env['HTTP_X_FORWARDED_FOR']
    end

    ip
  end

  def safe_render(template)
    render :plain => template.render(host: @host, params: params).html_safe
  rescue StandardError => error
    msg = _("There was an error rendering the %s template: ") % template.name
    Foreman::Logging.exception(msg, error)
    render :plain => msg + error.message, :status => :internal_server_error
  end
end
