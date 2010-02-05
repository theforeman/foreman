class UnattendedController < ApplicationController
  layout nil
  helper :all
  before_filter :get_host_details, :allowed_to_install?
  before_filter :handle_ca, :except => [:jumpstart_finish, :preseed_finish]
  skip_before_filter :require_ssl, :require_login

  def kickstart
    logger.info "#{controller_name}: Kickstart host #{@host.name}"
    @osver = @host.operatingsystem.major.to_i
    @arch = @host.architecture.name
  end

  def jumpstart_profile
  end

  def jumpstart_finish
  end

  def preseed
  end

  def preseed_finish
  end

# this actions is called by each operatingsystem post/finish script - it notify us that the OS installation is done.
  def built
    logger.info "#{controller_name}: #{@host.name} is Built!"
    @host.built
    head(:created) and return
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

    unless request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].nil?
      mac=request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].split[1].downcase.strip
    end

    conditions = (mac and ip) ? ["mac = ? and ip = ?",mac, ip] : ["ip = ?",ip];
    @host = Host.find(:first, :include => [:architecture, :media, :operatingsystem, :domain], :conditions => conditions)
    if @host.nil?
      logger.info "#{controller_name}: unable to find #{ip}#{"/"+mac unless mac.nil?}"
      head(:not_found) and return
    end
  end

  def allowed_to_install?
    @host.build or @spoof ? true : head(:method_not_allowed)
  end

  # Cleans Certificate and enable autosign
  def handle_ca
    #the reason we do it here is to minimize the amount of time it is possible to automatically get a certificate
    #through puppet.

    # we don't do anything if we are in spoof mode.
    return if @spoof

    return false unless GW::Puppetca.clean name
    return false unless GW::Puppetca.sign @host.name
  end
end
