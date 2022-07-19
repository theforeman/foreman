module Orchestration::TFTP
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :validate_tftp, :unless => :skip_orchestration?
    after_validation :queue_tftp
    before_destroy :queue_tftp_destroy

    # required for pxe template url helpers
    include Rails.application.routes.url_helpers
    register_rebuild(:rebuild_tftp, N_('TFTP'))
  end

  def tftp_ready?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    (host.nil? || host&.managed?) && managed && provision? && (host&.operatingsystem && host.pxe_loader.present?) && !image_build?
  end

  def tftp?
    tftp_ready? && !!(subnet && subnet.tftp?)
  end

  def tftp6?
    tftp_ready? && !!(subnet6 && subnet6.tftp?)
  end

  def tftp
    subnet.tftp_proxy if tftp?
  end

  def tftp6
    subnet6.tftp_proxy if tftp6?
  end

  def rebuild_tftp
    unless tftp? || tftp6?
      logger.info "TFTP not supported for #{name} (#{ip}/#{ip6}), skipping orchestration rebuild"
      return true
    end

    results = host.operatingsystem.template_kinds_for_tftp.map do |kind|
      rebuild_tftp_kind_safe(kind)
    end
    results.all?
  end

  def rebuild_tftp_kind_safe(kind)
    setTFTP(kind)
  rescue => e
    Foreman::Logging.exception "Failed to rebuild TFTP record for #{name} (#{ip}/#{ip6})", e, :level => :error
    false
  end

  def generate_pxe_template(kind)
    return build_pxe_render(kind) if build?
    default_pxe_render(kind)
  end

  protected

  def build_pxe_render(kind)
    template = host.provisioning_template({:kind => kind})
    return unless template.present?
    host.render_template(template: template)
  rescue => e
    failure _("Unable to render %{kind} template '%{name}': %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
  end

  def default_pxe_render(kind)
    template_name = host.local_boot_template_name(kind)
    # Safely return in case there's no template configured for the specified kind
    return unless template_name.present?
    template = ProvisioningTemplate.find_by_name(template_name)
    raise Foreman::Exception.new(N_("Template '%s' was not found"), template_name) unless template
    host.render_template(template: template)
  rescue => e
    failure _("Unable to render '%{name}' template: %{e}") % { :name => template_name, :e => e }, e
  end

  # Adds the host to the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def setTFTP(kind)
    content = generate_pxe_template(kind)
    if content
      logger.info "Deploying TFTP #{kind} configuration for #{host.name}"
      each_unique_feasible_tftp_proxy do |proxy|
        mac_addresses_for_provisioning.each do |mac_addr|
          proxy.set(kind, mac_addr, :pxeconfig => content)
        end
      end
    else
      logger.info "Skipping TFTP #{kind} configuration for #{host.name}"
      true
    end
  end

  # Removes the host from the forward and reverse TFTP zones
  # +returns+ : Boolean true on success
  def delTFTP(kind)
    logger.info "Delete the TFTP configuration for #{host.name}"
    each_unique_feasible_tftp_proxy do |proxy|
      mac_addresses_for_provisioning.each do |mac_addr|
        proxy.delete(kind, mac_addr)
      end
    end
  end

  def setTFTPBootFiles
    logger.info "Fetching required TFTP boot files for #{host.name}"
    valid = []

    # Check host.medium_provider path for iso image
    is_image_path = File.extname(host.medium_uri.to_s).downcase.end_with?(".iso")

    valid << each_unique_feasible_tftp_proxy do |proxy|
      bootfiles = host.operatingsystem.pxe_files(host.medium_provider)
      if is_image_path
        max_request_timeout = Setting[:proxy_request_timeout]
        image_url = host.medium_uri.to_s
        tftp_files = pxe_files_from_bootfiles(bootfiles, image_url)
        tftp_dst = pxe_dst_from_bootfiles(bootfiles)
        image_dst = host.operatingsystem.system_image_path(host.medium_provider, true, false)
        image_status = poll_fetch_system_image(proxy, image_url, image_dst, tftp_files, tftp_dst, max_request_timeout)
        logger.error "Timeout fetching system image #{image_url}. See smart proxy log for details." unless image_status
        image_status
      else
        bootfiles.each do |bootfile_info|
          bootfile_info.each do |prefix, path|
            proxy.fetch_boot_file(:prefix => prefix.to_s, :path => path)
          end
        end
      end
    end
    failure _("Failed to fetch boot files") unless valid.all?
    valid.all?
  end

  # empty method for rollbacks
  def delTFTPBootFiles
  end

  private

  def validate_tftp
    return unless tftp? || tftp6?
    return unless host.operatingsystem
    pxe_kind = host.operatingsystem.pxe_loader_kind(host)
    if pxe_kind && host.provisioning_template({:kind => pxe_kind}).nil?
      failure _("No %{template_kind} templates were found for this host, make sure you define at least one in your %{os} settings or change PXE loader") %
        { :template_kind => pxe_kind, :os => host.operatingsystem }
    end
  end

  def queue_tftp
    return log_orchestration_errors unless (tftp? || tftp6?) && no_errors
    # Jumpstart builds require only minimal tftp services. They do require a tftp object to query for the boot_server.
    return true if host.jumpstart?
    new_record? ? queue_tftp_create : queue_tftp_update
  end

  def queue_tftp_create
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Deploy TFTP %{kind} config for %{host}") % {:kind => kind, :host => self}, :priority => 20, :action => [self, :setTFTP, kind])
    end
    return unless build
    queue.create(:name => _("Fetch TFTP boot files for %s") % self, :priority => 25, :action => [self, :setTFTPBootFiles])
  end

  def queue_tftp_update
    set_tftp = false
    # we switched build mode
    set_tftp = true if old.host.build? != host.build?
    # medium or arch changed
    set_tftp = true if old.host.medium.try(:id) != host.medium.try(:id) || old.host.arch.try(:id) != host.arch.try(:id)
    # operating system changed
    set_tftp = true if host.operatingsystem && old.host.operatingsystem && (old.host.operatingsystem.name != host.operatingsystem.name || old.host.operatingsystem.try(:id) != host.operatingsystem.try(:id))
    # MAC address changed
    if mac != old.mac
      set_tftp = true
      # clean up old TFTP reservation file
      queue_tftp_destroy(false, 19, old) if old.tftp?
    end
    queue_tftp_create if set_tftp
  end

  def queue_tftp_destroy(validate = true, priority = 20, host = self)
    if validate
      return unless (tftp? || tftp6?) && no_errors
      return true if host.jumpstart?
    end
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Delete TFTP %{kind} config for %{host}") % {:kind => kind, :host => host}, :priority => priority, :action => [host, :delTFTP, kind])
    end
  end

  def no_errors
    errors.empty? && host.errors.empty?
  end

  def unique_feasible_tftp_proxies
    proxies = []
    proxies << tftp if tftp?
    proxies << tftp6 if tftp6?
    proxies.uniq { |p| p.url }
  end

  def each_unique_feasible_tftp_proxy
    results = unique_feasible_tftp_proxies.map do |proxy|
      yield(proxy)
    end
    results.all?
  end

  # Extract pxe files from bootfiles
  def pxe_files_from_bootfiles(bootfiles, image_url)
    pxe_files = []
    bootfiles.each { |pxe_url| pxe_files.append(pxe_url.values.first.delete_prefix(image_url)) }
    pxe_files
  end

  # Extract pxe destination file name from bootfiles
  def pxe_dst_from_bootfiles(bootfiles)
    bootfiles.first.keys.first
  end

  def poll_fetch_system_image(proxy, image_url, image_dst, tftp_files, tftp_dst, max_request_time)
    retries = poll_system_image_retries
    pause_time = max_request_time / poll_system_image_retries
    request_status = proxy.fetch_system_image(:url => image_url, :path => image_dst, :files => tftp_files, :tftp_path => tftp_dst)
    until retries <= 0 || request_status == 200
      sleep(pause_time)
      request_status = proxy.fetch_system_image(:url => image_url, :path => image_dst, :files => tftp_files, :tftp_path => tftp_dst)
      retries -= 1
    end
    request_status == 200
  end

  def poll_system_image_retries
    10
  end
end
