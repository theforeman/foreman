class UnattendedController < ApplicationController
  include Foreman::Renderer

  layout false

  # We dont require any of these methods for provisioning
  FILTERS = [:require_login, :session_expiry, :update_activity_time, :set_taxonomy, :authorize]
  FILTERS.each do |f|
    define_method("#{f}_with_unattended") do
      send("#{f}_without_unattended") if preview?
    end
    alias_method_chain f, :unattended
  end

  before_action :set_admin_user, :unless => Proc.new { preview? }
  # We want to find out our requesting host
  before_action :get_host_details, :allowed_to_install?, :except => :hostgroup_template
  before_action :handle_ca, :if => Proc.new { params[:kind] == 'provision' }
  before_action :handle_realm, :if => Proc.new { params[:kind] == 'provision' }
  # load "helper" variables to be available in the templates
  before_action :load_template_vars, :only => :host_template
  # all of our requests should be returned in text/plain
  after_action :set_content_type

  # this actions is called by each operatingsystem post/finish script - it notify us that the OS installation is done.
  def built
    logger.info "#{controller_name}: #{@host.name} is Built!"
    update_ip if Setting[:update_ip_from_built_request]
    head(@host.built ? :created : :conflict)
  end

  def hostgroup_template
    return head(:not_found) unless (params.has_key?("id") && params.has_key?(:hostgroup))

    template = ProvisioningTemplate.unscoped.find_by_name(params['id'].to_s)
    @host = Hostgroup.unscoped.find_by_title(params['hostgroup'].to_s)
    return head(:not_found) unless template && @host

    load_template_vars if template.template_kind.name == 'provision'
    safe_render template.template
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
    render(:text => '# ' + _(error_message) % params, :status => status, :content_type => 'text/plain')
  end

  def render_template(type)
    # Compatibility with older URLs
    type = 'iPXE' if type == 'gPXE'

    if (config = @host.provisioning_template({ :kind => type }))
      safe_render config
    else
      error_message = N_("unable to find %{type} template for %{host} running %{os}")
      render_custom_error(:not_found, error_message, {:type => type, :host => @host.name, :os => @host.operatingsystem})
    end
  end

  # lookup for a host based on the ip address and if possible by a mac address(as sent by anaconda)
  # if the host was found than its record will be in @host
  # if the host doesn't exists, it will return 404 and the requested method will not be reached.

  def get_host_details
    @host = find_host_by_spoof || find_host_by_token || find_host_by_ip_or_mac
    unless @host
      error_message = N_("%{controller}: unable to find a host that matches the request from %{addr}")
      render_custom_error(:not_found, error_message, {:controller => controller_name, :addr => request.env['REMOTE_ADDR']})
      return
    end
    unless @host.operatingsystem
      error_message = N_("%{controller}: %{host}'s operating system is missing")
      render_custom_error(:conflict, error_message, {:controller => controller_name, :host => @host.name})
      return
    end
    unless @host.operatingsystem.family
      error_message = N_("%{controller}: %{host}'s operating system %{os} has no OS family")
      render_custom_error(:conflict, error_message, {:controller => controller_name, :host => @host.name, :os => @host.operatingsystem.fullname})
      return
    end
    logger.debug "Found #{@host}"
  end

  def find_host_by_spoof
    host = Host.authorized('view_hosts').joins(:primary_interface).where("#{Nic::Base.table_name}.ip" => params['spoof']).first if params['spoof'].present?
    host ||= Host.authorized('view_hosts').find_by_name(params['hostname']) if params['hostname'].present?
    @spoof = host.present?
    host
  end

  def find_host_by_token
    token = params.delete('token')
    return nil if token.blank?
    # Quirk: ZTP requires the .slax suffix
    if (result = token.match(/^([a-z0-9-]+)(.slax)$/i))
      token, _suffix = result.captures
    end
    Host.for_token(token).first
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
    # we try to match first based on the MAC, falling back to the IP
    # host is readonly because of association so we reload it if we find it
    host = Host.joins(:provision_interface).where(mac_list.empty? ? {:nics => {:ip => ip}} : ["lower(nics.mac) IN (?)", mac_list]).first
    host ? Host.find(host.id) : nil
  end

  def allowed_to_install?
    (@host.build || @spoof || Setting[:access_unattended_without_build]) ? true : head(:method_not_allowed)
  end

  # Cleans Certificate and enable autosign. This is run as a before_action for provisioning templates.
  # The host is requesting its build configuration so I guess we just send them some text so a post mortum can see what happened
  def handle_ca
    # The reason we do it here is to minimize the amount of time it is possible to automatically get a certificate

    # We don't do anything if we are in spoof mode.
    return true if @spoof

    # This should terminate the before_action and the action. We return a HTTP
    # error so the installer knows something is wrong. This is tested with
    # Anaconda, but maybe Suninstall will choke on it.
    render(:text => _("Failed to clean any old certificates or add the autosign entry. Terminating the build!"), :status => :internal_server_error) unless @host.handle_ca
    #TODO: Email the user who initiated this build operation.
  end

  # Reset realm OTP. This is run as a before_action for provisioning templates.
  def handle_realm
    # We don't do anything if we are in spoof mode.
    return true if @spoof

    # This should terminate the before_action and the action. We return a HTTP
    # error so the installer knows something is wrong. This is tested with
    # Anaconda, but maybe Suninstall will choke on it.
    render(:text => _("Failed to get a new realm OTP. Terminating the build!"), :status => :internal_server_error) unless @host.handle_realm
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
    @host.ip = old_ip unless @host.update_attributes({'ip' => ip})
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
    if template.is_a?(String)
      @unsafe_template_content = template
      @template_name = 'Unnamed'
    elsif template.is_a?(ProvisioningTemplate)
      @unsafe_template_content = template.template
      @template_name = template.name
    else
      raise "unknown template"
    end

    begin
      render :inline => "<%= unattended_render(@unsafe_template_content, @template_name).html_safe %>"
    rescue => error
      msg = _("There was an error rendering the %s template: ") % (@template_name)
      Foreman::Logging.exception(msg, error)
      render :text => msg + error.message, :status => :internal_server_error
    end
  end
end
