class UnattendedController < ApplicationController
  layout nil

  # Methods which return configuration files for syslinux(pxe), pxegrub or g/ipxe
  PXE_CONFIG_URLS = [:pxe_kickstart_config, :pxe_debian_config, :pxemenu] + TemplateKind.where("name LIKE ?","pxelinux").map(&:name)
  PXEGRUB_CONFIG_URLS = [:pxe_jumpstart_config] + TemplateKind.where("name LIKE ?", "pxegrub").map(&:name)
  GPXE_CONFIG_URLS = [:gpxe_kickstart_config] + TemplateKind.where("name LIKE ?", "gpxe").map(&:name)
  CONFIG_URLS = PXE_CONFIG_URLS + GPXE_CONFIG_URLS + PXEGRUB_CONFIG_URLS
  # Methods which return valid provision instructions, used by the OS
  PROVISION_URLS = [:kickstart, :preseed, :jumpstart ] + TemplateKind.where("name LIKE ?", "provision").map(&:name)
  # Methods which returns post install instructions for OS's which require it
  FINISH_URLS = [:preseed_finish, :jumpstart_finish] + TemplateKind.where("name LIKE ?", "finish").map(&:name)

  # We dont require any of these methods for provisioning
  FILTERS = [:require_ssl, :require_login, :session_expiry, :update_activity_time, :set_taxonomy, :authorize]
  FILTERS.each do |f|
    define_method("#{f}_with_unattended") do
      send("#{f}_without_unattended") if params.keys.include?("spoof")
    end
    alias_method_chain f, :unattended
  end

  # We want to find out our requesting host
  before_filter :get_host_details, :allowed_to_install?, :except => :template
  before_filter :handle_ca, :only => PROVISION_URLS
  # load "helper" variables to be available in the templates
  before_filter :load_template_vars, :only => PROVISION_URLS
  before_filter :pxe_config, :only => CONFIG_URLS
  # all of our requests should be returned in text/plain
  after_filter :set_content_type
  before_filter :set_admin_user, :only => :built

  def kickstart
    unattended_local
  end

  def preseed
    unattended_local
  end

  def preseed_finish
    unattended_local
  end

  # this actions is called by each operatingsystem post/finish script - it notify us that the OS installation is done.
  def built
    logger.info "#{controller_name}: #{@host.name} is Built!"
    head(@host.built ? :created : :conflict)
  end

  def template
    return head(:not_found) unless (params.has_key?("id") and params.has_key?(:hostgroup))

    template = ConfigTemplate.find_by_name(params['id'])
    @host = Hostgroup.find_by_name(params['hostgroup'])

    return head(:not_found) unless template and @host

    load_template_vars if template.template_kind.name == 'provision'
    safe_render template.template
  end

  # Returns a valid GPXE config file to kickstart hosts
  def gpxe_kickstart_config
  end

  def pxe_config
    @kernel = @host.operatingsystem.kernel @host.arch
    @initrd = @host.operatingsystem.initrd @host.arch
  end

  # Generate an action for each template kind
  # i.e. /unattended/provision will render the provisioning template for the requesting host
  TemplateKind.all.each do |kind|
    define_method kind.name do
      @type = kind.name
      unattended_local
    end
  end

  private

  # lookup for a host based on the ip address and if possible by a mac address(as sent by anaconda)
  # if the host was found than its record will be in @host
  # if the host doesn't exists, it will return 404 and the requested method will not be reached.

  def get_host_details
    @host = find_host_by_spoof || find_host_by_token || find_host_by_ip_or_mac
    unless @host
      logger.info "#{controller_name}: unable to find a host that matches the request from #{request.env['REMOTE_ADDR']}"
      head(:not_found) and return
    end
    unless @host.operatingsystem
      logger.error "#{controller_name}: #{@host.name}'s operating system is missing!"
      head(:conflict) and return
    end
    unless @host.operatingsystem.family
      # Then, for some reason, the OS has not been specialized into a Redhat or Debian class
      logger.error "#{controller_name}: #{@host.name}'s operating system [#{@host.operatingsystem.fullname}] has no OS family!"
      head(:conflict) and return
    end
    logger.info "Found #{@host}"
  end

  def find_host_by_spoof
    spoof = params.delete("spoof")
    return nil if spoof.blank?
    @spoof = true
    Host.find_by_ip(spoof)
  end

  def find_host_by_token
    token = params.delete("token")
    return nil if token.blank?
    Host.for_token(token).first
  end

  def find_host_by_ip_or_mac
    # try to find host based on our client ip address
    ip = request.env['REMOTE_ADDR']

    # check if someone is asking on behave of another system (load balance etc)
    if request.env['HTTP_X_FORWARDED_FOR'].present? and (ip =~ Regexp.new(Setting[:remote_addr]))
      ip = request.env['HTTP_X_FORWARDED_FOR']
    end

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
        logger.info "unknown RHN_PROVISIONING header #{e}"
        mac_list = []
      end
    end
    # we try to match first based on the MAC, falling back to the IP
    Host.where(mac_list.empty? ? { :ip => ip } : ["lower(mac) IN (?)", mac_list]).first
  end

  def allowed_to_install?
    (@host.build or @spoof) ? true : head(:method_not_allowed)
  end

  # Cleans Certificate and enable autosign. This is run as a before_filter for provisioning templates.
  # The host is requesting its build configuration so I guess we just send them some text so a post mortum can see what happened
  def handle_ca
    # The reason we do it here is to minimize the amount of time it is possible to automatically get a certificate

    # We don't do anything if we are in spoof mode.
    return true if @spoof

    # This should terminate the before_filter and the action. We return a HTTP
    # error so the installer knows something is wrong. This is tested with
    # Anaconda, but maybe Suninstall will choke on it.
    render(:text => "Failed to clean any old certificates or add the autosign entry. Terminating the build!", :status => 500) unless @host.handle_ca
    #TODO: Email the user who initiated this build operation.
  end

  # we try to find this host specific template
  # if it doesn't exists, we'll try to find a local generic template
  # otherwise render the default view
  def unattended_local
    if (config = @host.configTemplate({ :kind => @type }))
      logger.debug "rendering DB template #{config.name} - #{@type}"
      safe_render config and return
    end
    type = "unattended_local/#{request.path.gsub("/#{controller_name}/","")}.local"
    render :template => type if File.exists?("#{Rails.root}/app/views/#{type}.rhtml")
  end

  def set_content_type
    response.headers['Content-Type'] = 'text/plain'
  end

  def load_template_vars
    # load the os family default variables
    eval "#{@host.os.pxe_type}_attributes"
  end

  def jumpstart_attributes
    if @host.operatingsystem.supports_image and @host.use_image
      @install_type     = "flash_install"
      # We have an individual override for the host's image file
      if @host.image_file
        @archive_location = @host.image_file
      else
        @archive_location = @host.default_image_file
      end
    else
      @install_type = "initial_install"
      @system_type  = "standalone"
      @cluster      = "SUNWCreq"
      @packages     = "SUNWgzip"
      @locale       = "C"
    end
    @disk = @host.diskLayout
  end

  def kickstart_attributes
    @dynamic   = @host.diskLayout =~ /^#Dynamic/
    @arch      = @host.architecture.name
    os         = @host.operatingsystem
    @osver     = os.major.to_i
    @mediapath = os.mediumpath @host
    @epel      = os.epel      @host
    @yumrepo   = os.yumrepo   @host

    # force static network configuration if static http parameter is defined, in the future this needs to go into the GUI
    @static = !params[:static].empty?
  end

  def preseed_attributes
    @preseed_path   = @host.os.preseed_path   @host
    @preseed_server = @host.os.preseed_server @host
  end

  def yast_attributes
  end

  def aif_attributes
    os         = @host.operatingsystem
    @mediapath = os.mediumpath @host
  end

  def waik_attributes
  end

  private

  def safe_render template
    template_name = ""
    if template.is_a?(String)
      @unsafe_template  = template
    elsif template.is_a?(ConfigTemplate)
      @unsafe_template  = template.template
      template_name = template.name
    else
      raise "unknown template"
    end

    begin
      render :inline => "<%= unattended_render(@unsafe_template).html_safe %>" and return
    rescue Exception => exc
      msg = "There was an error rendering the " + template_name + " template: "
      render :text => msg + exc.message, :status => 500 and return
    end
  end


end
