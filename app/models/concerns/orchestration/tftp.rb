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
    @bootloader_universe_plan_checked = false
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

  def generate_pxe_template(kind, mac_addr: nil)
    return build_pxe_render(kind, mac_addr: mac_addr) if build?
    default_pxe_render(kind)
  end

  protected

  def build_pxe_render(kind, mac_addr: nil)
    template = host.provisioning_template({:kind => kind})
    return unless template.present?
    boot_files = bootloader_universe_plan if bootloader_universe_template?(kind)
    variables = boot_files ? { universe_boot_files: boot_files } : {}
    variables[:boot_mac] = mac_addr if boot_files && mac_addr
    host.render_template(template: template, variables: variables)
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
    mac_addresses = mac_addresses_for_provisioning
    boot_files = bootloader_universe_plan if bootloader_universe_template?(kind)
    content_by_mac = if boot_files
                       mac_addresses.index_with { |mac_addr| generate_pxe_template(kind, mac_addr: mac_addr) }
                     else
                       content = generate_pxe_template(kind)
                       mac_addresses.index_with { content }
                     end
    if content_by_mac.values.any?
      return false unless content_by_mac.values.all?

      logger.info "Deploying TFTP #{kind} configuration for #{host.name}"
      each_unique_feasible_tftp_proxy do |proxy|
        mac_addresses.each do |mac_addr|
          args = {
                      :pxeconfig => content_by_mac[mac_addr],
                      :targetos => host.operatingsystem.name.downcase,
                      :release => host.operatingsystem.release,
                      :arch => host.arch.name,
                      :bootfile_suffix => host.arch.bootfilename_efi,
                    }
          if boot_files
            args.merge!(universe_archive: boot_files[:archive], universe_kernel: boot_files[:kernel],
              universe_initrd: boot_files[:initrd], universe_source_digest: boot_files[:source_digest])
          end
          begin
            proxy.set(kind, mac_addr, args)
          rescue ProxyAPI::ProxyException => e
            # A 409 can also mean boot files are still being downloaded.
            if boot_files && e.wrapped_exception.respond_to?(:http_code) && e.wrapped_exception.http_code == 409
              return failure(_("Boot files missing, sync boot files for %{os}") %
                { os: host.operatingsystem.fullname }, e)
            end
            raise
          end
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
    if bootloader_universe_plan
      logger.info "Using managed bootloader universe files for #{host.name}"
      return true
    end

    logger.info "Fetching required TFTP boot files for #{host.name}"
    valid = []

    host.operatingsystem.pxe_files(host.medium_provider).each do |bootfile_info|
      bootfile_info.each do |prefix, path|
        valid << each_unique_feasible_tftp_proxy do |proxy|
          proxy.fetch_boot_file(:prefix => prefix.to_s, :path => path)
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
    @bootloader_universe_plan_checked = false
    return log_orchestration_errors unless (tftp? || tftp6?) && no_errors
    # Jumpstart builds require only minimal tftp services. They do require a tftp object to query for the boot_server.
    return true if host.jumpstart?
    new_record? ? queue_tftp_create : queue_tftp_update
  rescue Foreman::BootloaderUniverse::HostBootFiles::NotReady => e
    failure(e.message)
  end

  def queue_tftp_create
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Deploy TFTP %{kind} config for %{host}") % {:kind => kind, :host => self}, :priority => 20, :action => [self, :setTFTP, kind])
    end
    return unless build
    return if bootloader_universe_plan

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

  def each_unique_feasible_tftp_proxy(&block)
    results = unique_feasible_tftp_proxies.map(&block)
    results.all?
  end

  def bootloader_universe_plan
    return @bootloader_universe_plan if @bootloader_universe_plan_checked

    @bootloader_universe_plan = Foreman::BootloaderUniverse::HostBootFiles.new(host).call
    @bootloader_universe_plan_checked = true
    @bootloader_universe_plan
  end

  def bootloader_universe_template?(kind)
    host.operatingsystem&.pxe_loader_kind(host).to_s == kind.to_s
  end
end
