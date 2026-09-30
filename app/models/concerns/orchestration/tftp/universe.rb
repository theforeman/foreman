module Orchestration::TFTP::Universe
  extend ActiveSupport::Concern

  # Adds the host to the forward and reverse TFTP zones (bootloader universe path)
  # Non-selected template kinds fall back to the legacy deploy path.
  # +returns+ : Boolean true on success
  def set_tftp_universe(kind)
    return set_tftp_legacy(kind) unless bootloader_universe_template?(kind)

    boot_files = bootloader_universe_plan
    return set_tftp_legacy(kind) unless boot_files

    mac_addresses = mac_addresses_for_provisioning
    content_by_mac = mac_addresses.index_with { |mac_addr| generate_pxe_template(kind, mac_addr: mac_addr) }

    if content_by_mac.values.any?
      return false unless content_by_mac.values.all?

      logger.info "Deploying TFTP #{kind} configuration for #{host.name}"
      each_unique_feasible_tftp_proxy do |proxy|
        mac_addresses.each do |mac_addr|
          args = tftp_proxy_deploy_args(kind, content_by_mac[mac_addr]).merge(
            universe_archive: boot_files[:archive],
            universe_kernel: boot_files[:kernel],
            universe_initrd: boot_files[:initrd],
            universe_source_digest: boot_files[:source_digest]
          )
          begin
            proxy.set(kind, mac_addr, args)
          rescue ProxyAPI::ProxyException => e
            # A 409 can also mean boot files are still being downloaded.
            if e.wrapped_exception.respond_to?(:http_code) && e.wrapped_exception.http_code == 409
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

  protected

  def build_pxe_render_universe(kind, mac_addr: nil)
    template = host.provisioning_template({:kind => kind})
    return unless template.present?
    boot_files = bootloader_universe_plan
    variables = { universe_boot_files: boot_files }
    variables[:boot_mac] = mac_addr if mac_addr
    host.render_template(template: template, variables: variables)
  rescue => e
    failure _("Unable to render %{kind} template '%{name}': %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
  end

  private

  def queue_tftp_universe_create
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Deploy TFTP %{kind} universe config for %{host}") % {:kind => kind, :host => self}, :priority => 20, :action => [self, :set_tftp_universe, kind])
    end
  end
end
