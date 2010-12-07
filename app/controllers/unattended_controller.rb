class UnattendedController < ApplicationController
  layout nil

  # Methods which return configuration files for syslinux(pxe) or gpxe
  PXE_CONFIG_URLS = [:pxe_kickstart_config, :pxe_debian_config] + TemplateKind.name_like("pxelinux").map(&:name)
  GPXE_CONFIG_URLS = [:gpxe_kickstart_config] + TemplateKind.name_like("gpxe").map(&:name)
  CONFIG_URLS = PXE_CONFIG_URLS + GPXE_CONFIG_URLS
  # Methods which return valid provision instructions, used by the OS
  PROVISION_URLS = [:kickstart, :preseed, :jumpstart_profile ] + TemplateKind.name_like("provision").map(&:name)
  # Methods which returns post install instructions for OS's which require it
  FINISH_URLS = [:preseed_finish, :jumpstart_finish] + TemplateKind.name_like("finish").map(&:name)

  # We dont require any of these methods for provisioning
  skip_before_filter :require_ssl, :require_login, :authorize, :load_tabs, :manage_tabs

  # We want to find out our requesting host
  before_filter :get_host_details,:allowed_to_install?, :except => PXE_CONFIG_URLS
  before_filter :handle_ca, :only => PROVISION_URLS
  # load "helper" variables to be available in the templates
  before_filter :load_template_vars, :only => PROVISION_URLS
  # all of our requests should be returned in text/plain
  after_filter :set_content_type
  before_filter :set_admin_user, :only => :built

  def kickstart
    unattended_local
  end

  def jumpstart_profile
    unattended_local
  end

  def jumpstart_finish
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

  def pxe_kickstart_config
    @host = Host.find_by_name params[:host_id]
    prefix = @host.operatingsystem.pxe_prefix(@host.arch)
    @kernel = "#{prefix}-#{Redhat::PXEFILES[:kernel]}"
    @initrd = "#{prefix}-#{Redhat::PXEFILES[:initrd]}"
  end

  # Returns a valid GPXE config file to kickstart hosts
  def gpxe_kickstart_config
  end

  def pxe_debian_config
    @host = Host.find_by_name params[:host_id]
    prefix = @host.operatingsystem.pxe_prefix(@host.arch)
    @kernel = "#{prefix}-#{Debian::PXEFILES[:kernel]}"
    @initrd = "#{prefix}-#{Debian::PXEFILES[:initrd]}"
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
    # find out ip info
    if params.has_key? "spoof"
      ip = params.delete("spoof")
      @spoof = true
    elsif (ip = request.env['REMOTE_ADDR']) =~ /127.0.0/
      ip = request.env["HTTP_X_FORWARDED_FOR"] unless request.env["HTTP_X_FORWARDED_FOR"].nil?
    end

    # search for a mac address in any of the RHN provsioning headers
    # this section is kickstart only relevant
    maclist = []
    unless request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].nil?
      begin
        request.env.keys.each do | header |
          maclist << request.env[header].split[1].downcase.strip if header =~ /^HTTP_X_RHN_PROVISIONING_MAC_/
        end
      rescue => e
        logger.info "unknown RHN_PROVISIONING header #{e}"
      end
    end

    # we try to match first based on the MAC, falling back to the IP
    conditions = (!maclist.empty? ? {:mac => maclist} : {:ip => ip})
    @host = Host.find(:first, :include => [:architecture, :media, :operatingsystem, :domain], :conditions => conditions)
    unless @host
      logger.info "#{controller_name}: unable to find ip/mac match for #{ip}"
      head(:not_found) and return
    end
    unless @host.operatingsystem
      logger.error "#{controller_name}: #{@host.name}'s operatingsystem is missing!"
      head(:conflict) and return
    end
    unless @host.operatingsystem.family
      # Then, for some reason, the OS has not been specialized into a Redhat or Debian class
      logger.error "#{controller_name}: #{@host.name}'s operatingsytem [#{@host.operatingsystem.fullname}] has no OS family!"
      head(:conflict) and return
    end
    logger.info "Found #{@host}"
  end

  def allowed_to_install?
    (@host.build or @spoof) ? true : head(:method_not_allowed)
  end

  # Cleans Certificate and enable autosign
  def handle_ca
    #the reason we do it here is to minimize the amount of time it is possible to automatically get a certificate
    #through puppet.

    # we don't do anything if we are in spoof mode.
    return if @spoof

    return false unless GW::Puppetca.clean @host.name
    return false unless GW::Puppetca.sign @host.name
  end

  # we try to find this host specific template
  # if it doesnt exists, we'll try to find a local generic template
  # otherwise render the default view
  def unattended_local
    if config = @host.configTemplate(@type)
      logger.debug "rendering DB template #{config.name} - #{@type}"
      @unsafe_template = config.template
      render :inline => "<%= render_sandbox(@unsafe_template) %>" and return
    end
    type = "unattended_local/#{request.path.gsub("/#{controller_name}/","")}.local"
    render :template => type if File.exists?("#{RAILS_ROOT}/app/views/#{type}.rhtml")
  end

  def set_content_type
    response.headers['Content-Type'] = 'text/plain'
  end

  def load_template_vars
    # load the os family default variables
    eval "#{@host.os.pxe_type}_attributes"
  end

  def kickstart_attributes
    @dynamic   = @host.diskLayout =~ /^#Dynamic/
    @arch      = @host.architecture.name
    os         = @host.operatingsystem
    @osver     = os.major.to_i
    @mediapath = os.mediapath @host
    @epel      = os.epel      @host
    @yumrepo   = os.yumrepo   @host

    # force static network configurtion if static http parameter is defined, in the future this needs to go into the GUI
    @static = !params[:static].empty?
  end

  def preseed_attributes
    @preseed_path   = @host.os.preseed_path   @host
    @preseed_server = @host.os.preseed_server @host
  end

end
