module Orchestration::TFTP::Legacy
  extend ActiveSupport::Concern

  # Adds the host to the forward and reverse TFTP zones (legacy medium/boot files path)
  # +returns+ : Boolean true on success
  def set_tftp_legacy(kind)
    content = generate_pxe_template(kind)
    mac_addresses = mac_addresses_for_provisioning
    content_by_mac = mac_addresses.index_with { content }

    if content_by_mac.values.any?
      return false unless content_by_mac.values.all?

      logger.info "Deploying TFTP #{kind} configuration for #{host.name}"
      each_unique_feasible_tftp_proxy do |proxy|
        mac_addresses.each do |mac_addr|
          proxy.set(kind, mac_addr, tftp_proxy_deploy_args(kind, content_by_mac[mac_addr]))
        end
      end
    else
      logger.info "Skipping TFTP #{kind} configuration for #{host.name}"
      true
    end
  end

  def set_tftp_boot_files
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
  def del_tftp_boot_files
  end

  protected

  def build_pxe_render_legacy(kind)
    template = host.provisioning_template({:kind => kind})
    return unless template.present?
    host.render_template(template: template, variables: {})
  rescue => e
    failure _("Unable to render %{kind} template '%{name}': %{e}") % { :kind => kind, :name => template.try(:name), :e => e }, e
  end

  private

  def queue_tftp_legacy_create
    host.operatingsystem.template_kinds.each do |kind|
      queue.create(:name => _("Deploy TFTP %{kind} legacy config for %{host}") % {:kind => kind, :host => self}, :priority => 20, :action => [self, :set_tftp_legacy, kind])
    end
    return unless build

    queue.create(:name => _("Fetch TFTP boot files for %s") % self, :priority => 25, :action => [self, :set_tftp_boot_files])
  end
end
