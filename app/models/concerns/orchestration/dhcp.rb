module Orchestration::DHCP
  extend ActiveSupport::Concern
  include Orchestration::Common

  included do
    after_validation :dhcp_conflict_detected?, :unless => :skip_orchestration?
    after_validation :queue_dhcp
    before_destroy :queue_dhcp_destroy
    register_rebuild(:rebuild_dhcp, N_('DHCP'))
  end

  def dhcp?
    # host.managed? and managed? should always come first so that orchestration doesn't
    # even get tested for such objects
    #
    # The subnet boot mode is ignored as DHCP can be required for PXE or image provisioning
    # steps, while boot mode can be used in templates later.
    (host.nil? || host.managed?) && managed? && hostname.present? && ip_available? && mac_available? &&
        !subnet.nil? && subnet.dhcp? && (!provision? || operatingsystem.present?)
  end

  def generate_dhcp_task_id(action, interface = self)
    id = [interface.mac, interface.ip, interface.identifier, interface.id].find { |x| x&.present? }
    "dhcp_#{action}_#{id}"
  end

  def dhcp_records
    return [] unless dhcp?
    @dhcp_records ||= mac_addresses_for_provisioning.map do |record_mac|
      build_dhcp_record(record_mac)
    end
  end

  def reset_dhcp_record_cache
    @dhcp_records = nil
  end

  def rebuild_dhcp
    unless dhcp?
      logger.info "DHCP not supported for #{name}, #{ip}, skipping orchestration rebuild"
      return true
    end

    del_dhcp_safe
    begin
      set_dhcp
    rescue => e
      Foreman::Logging.exception "Failed to rebuild DHCP record for #{name}, #{ip}", e, :level => :error
      false
    end
  end

  protected

  def del_dhcp_safe
    del_dhcp
  rescue => e
    Foreman::Logging.exception "Proxy failed to delete DHCP record for #{name}, #{ip}", e, :level => :error
  end

  def set_dhcp
    dhcp_records.all? { |record| record.create }
  end

  def set_dhcp_conflicts
    dhcp_records.all? do |record|
      record.conflicts.each { |conflict| conflict.create }
    end
  end

  def del_dhcp
    dhcp_records.all? { |record| record.destroy }
  end

  def del_dhcp_conflicts
    dhcp_records.all? do |record|
      record.conflicts.all? { |conflict| conflict.destroy }
    end
  end

  def boot_server
    return unless tftp?

    unless subnet.dhcp.has_capability?(:DHCP, :dhcp_filename_hostname)
      logger.warn "DHCP proxy does not report dhcp_filename_ipv4 or dhcp_filename_hostname capability. Foreman will pass boot server #{boot_server_or_proxy_hostname} as-is, the request might fail."
    end

    boot_server_or_proxy_hostname
  end

  def boot_server_or_proxy_hostname
    return tftp.bootServer if tftp.bootServer.present?

    tftp_proxy_hostname = URI.parse(subnet.tftp.url).host
    logger.warn "Using TFTP Smart Proxy hostname as the boot server name: #{tftp_proxy_hostname}"
    tftp_proxy_hostname
  end

  private

  def build_dhcp_record(record_mac)
    raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
    record_attrs = dhcp_attrs(record_mac)
    record_type = operatingsystem.dhcp_record_type

    handle_validation_errors do
      record_type.new(record_attrs)
    end
  end

  # returns a hash of dhcp record settings
  def dhcp_attrs(record_mac)
    raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?

    dhcp_attr = {
      :name => dhcp_record_name(record_mac),
      :hostname => hostname,
      :ip => ip,
      :mac => record_mac,
      :proxy => subnet.dhcp_proxy,
      :network => subnet.network,
      :related_macs => mac_addresses_for_provisioning - [record_mac],
    }

    if provision?
      dhcp_attr[:nextServer] = boot_server unless host.pxe_loader == 'None'
      filename = operatingsystem.boot_filename(host)
      dhcp_attr[:filename] = filename if filename.present?
      if jumpstart?
        jumpstart_arguments = os.jumpstart_params host, model.vendor_class
        dhcp_attr.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      elsif operatingsystem.respond_to?(:pxe_type) && operatingsystem.pxe_type == "ZTP" && operatingsystem.respond_to?(:ztp_arguments)
        ztp_arguments = os.ztp_arguments host
        dhcp_attr.merge! ztp_arguments unless ztp_arguments.empty?
      end
    end

    dhcp_attr
  end

  def dhcp_record_name(record_mac)
    return name if mac_addresses_for_provisioning.size <= 1
    "#{name}-#{'%02d' % (mac_addresses_for_provisioning.index(record_mac) + 1)}"
  end

  def queue_dhcp
    return log_orchestration_errors unless (dhcp? || old&.dhcp?) && orchestration_errors?
    queue_remove_dhcp_conflicts
    new_record? ? queue_dhcp_create : queue_dhcp_update
  end

  def queue_dhcp_create
    logger.debug "Scheduling new DHCP reservations for #{self}"
    queue.create(id: generate_dhcp_task_id("create"), name: _("Create DHCP Settings for %s") % self, priority: 10, action: [self, :set_dhcp]) if dhcp?
  end

  def queue_dhcp_update
    return unless dhcp_update_required?
    logger.debug("Detected a changed required for DHCP record")
    queue.create(id: generate_dhcp_task_id("remove", old), name: _("Remove DHCP Settings for %s") % old, priority: 5, action: [old, :del_dhcp]) if old.dhcp?
    queue.create(id: generate_dhcp_task_id("create"), name: _("Create DHCP Settings for %s") % self, priority: 9, action: [self, :set_dhcp]) if dhcp?
  end

  # do we need to update our dhcp reservations
  def dhcp_update_required?
    # IP Address / name changed, or 'rebuild' action is triggered and DHCP record on the smart proxy is not present/identical.
    return true if ((old.ip != ip) ||
      (old.hostname != hostname) ||
      provision_mac_addresses_changed? ||
      (old.subnet != subnet) ||
      (old&.operatingsystem&.boot_filename(old.host) != operatingsystem&.boot_filename(host)) ||
      ((old.host.pxe_loader == "iPXE Embedded" || host.pxe_loader == "iPXE Embedded") && (old.host.build != host.build)) ||
      (!old.build? && build? && !all_dhcp_records_valid?))
    # Handle jumpstart
    # TODO, abstract this way once interfaces are fully used
    if is_a?(Host::Base) && jumpstart?
      if !old.build? || (old.medium != medium || old.arch != arch) ||
          (os && old.os && (old.os.name != os.name || old.os != os))
        return true
      end
    end
    false
  end

  def all_dhcp_records_valid?
    dhcp_records.all? { |record| record.valid? }
  end

  def queue_dhcp_destroy
    return unless dhcp? && errors.empty?
    queue.create(id: generate_dhcp_task_id("remove"), name: _("Remove DHCP Settings for %s") % self, priority: 5, action: [self, :del_dhcp])
    true
  end

  def queue_remove_dhcp_conflicts
    return if !dhcp? || !overwrite?

    logger.debug "Scheduling DHCP conflicts removal"
    queue.create(id: generate_dhcp_task_id("conflicts_remove"), name: _("DHCP conflicts removal for %s") % self, priority: 5, action: [self, :del_dhcp_conflicts])
  end

  def dhcp_conflict_detected?
    # we can't do any dhcp based validations when our MAC address is defined afterwards (e.g. in vm creation)
    return false if mac.blank? || hostname.blank?
    return false unless dhcp?

    if dhcp_records.any? && dhcp_records.any? { |record| record.conflicting? } && !overwrite?
      failure(_("DHCP records %s already exists") % dhcp_records.map { |record| record.conflicts }.flatten.to_sentence, nil, :conflict) # compact?
      return true
    end
    false
  end

  def provision_mac_addresses_changed?
    old.mac_addresses_for_provisioning != mac_addresses_for_provisioning
  end
end
