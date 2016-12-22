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
        !subnet.nil? && subnet.dhcp? && SETTINGS[:unattended] && (!provision? || operatingsystem.present?)
  end

  def dhcp_record
    return unless dhcp? || @dhcp_record
    handle_validation_errors do
      @dhcp_record ||= (provision? && jumpstart?) ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end
  end

  def reset_dhcp_record_cache
    @dhcp_record = nil
  end

  def rebuild_dhcp
    if dhcp?
      del_dhcp_safe
      begin
        set_dhcp
      rescue => e
        Foreman::Logging.exception "Failed to rebuild DHCP record for #{name}, #{ip}", e, :level => :error
        false
      end
    else
      logger.info "DHCP not supported for #{name}, #{ip}, skipping orchestration rebuild"
      true
    end
  end

  protected

  def del_dhcp_safe
    if dhcp_record
      begin
        del_dhcp
      rescue => e
        Foreman::Logging.exception "Proxy failed to delete DHCP record for #{name}, #{ip}", e, :level => :error
      end
    end
  end

  def set_dhcp
    dhcp_record.create
  end

  def set_dhcp_conflicts
    dhcp_record.conflicts.each{|conflict| conflict.create}
  end

  def del_dhcp
    dhcp_record.destroy
  end

  def del_dhcp_conflicts
    dhcp_record.conflicts.each{|conflict| conflict.destroy}
  end

  # where are we booting from
  def boot_server
    # if we don't manage tftp for IPv4 at all, we dont create a next-server entry.
    return unless tftp?

    # first try to ask our IPv4 TFTP server for its boot server
    bs = tftp.bootServer
    # if that failed, trying to guess out tftp next server based on the smart proxy hostname
    bs ||= URI.parse(subnet.tftp.url).host
    # now convert it into an ip address (see http://theforeman.org/issues/show/1381)
    ip = NicIpResolver.new(:nic => self).to_ip_address(bs) if bs.present?
    return ip unless ip.nil?

    failure _("Unable to determine the host's boot server. The DHCP smart proxy failed to provide this information and this subnet is not provided with TFTP services.")
  rescue => e
    failure _("failed to detect boot server: %s") % e, e
  end

  private

  # returns a hash of dhcp record settings
  def dhcp_attrs
    raise ::Foreman::Exception.new(N_("DHCP not supported for this NIC")) unless dhcp?
    dhcp_attr = {
      :name => name,
      :hostname => hostname,
      :ip => ip,
      :mac => mac,
      :proxy => subnet.dhcp_proxy,
      :network => subnet.network
    }

    if provision?
      dhcp_attr.merge!(:nextServer => boot_server)
      filename = operatingsystem.boot_filename(self.host)
      dhcp_attr.merge!(:filename => filename) if filename.present?
      if jumpstart?
        jumpstart_arguments = os.jumpstart_params self.host, model.vendor_class
        dhcp_attr.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
    end

    dhcp_attr
  end

  def queue_dhcp
    return unless (dhcp? || (old && old.dhcp?)) && orchestration_errors?
    queue_remove_dhcp_conflicts
    new_record? ? queue_dhcp_create : queue_dhcp_update
  end

  def queue_dhcp_create
    logger.debug "Scheduling new DHCP reservations for #{self}"
    queue.create(:name   => _("Create DHCP Settings for %s") % self, :priority => 10,
                 :action => [self, :set_dhcp]) if dhcp?
  end

  def queue_dhcp_update
    if dhcp_update_required?
      logger.debug("Detected a changed required for DHCP record")
      queue.create(:name => _("Remove DHCP Settings for %s") % old, :priority => 5,
                   :action => [old, :del_dhcp]) if old.dhcp?
      queue.create(:name   => _("Create DHCP Settings for %s") % self, :priority => 9,
                   :action => [self, :set_dhcp]) if dhcp?
    end
  end

  # do we need to update our dhcp reservations
  def dhcp_update_required?
    # IP Address / name changed, or 'rebuild' action is triggered and DHCP record on the smart proxy is not present/identical.
    return true if ((old.ip != ip) || (old.hostname != hostname) || (old.mac != mac) || (old.subnet != subnet) || (operatingsystem.boot_filename(old.host) != operatingsystem.boot_filename(self.host)) ||
                    (!old.build? && build? && !dhcp_record.valid?))
    # Handle jumpstart
    #TODO, abstract this way once interfaces are fully used
    if self.is_a?(Host::Base) && jumpstart?
      if !old.build? || (old.medium != medium || old.arch != arch) ||
          (os && old.os && (old.os.name != os.name || old.os != os))
        return true
      end
    end
    false
  end

  def queue_dhcp_destroy
    return unless dhcp? && errors.empty?
    queue.create(:name   => _("Remove DHCP Settings for %s") % self, :priority => 5,
                 :action => [self, :del_dhcp])
    true
  end

  def queue_remove_dhcp_conflicts
    return if !dhcp? || !overwrite?

    logger.debug "Scheduling DHCP conflicts removal"
    queue.create(:name   => _("DHCP conflicts removal for %s") % self, :priority => 5,
                 :action => [self, :del_dhcp_conflicts])
  end

  def dhcp_conflict_detected?
    # we can't do any dhcp based validations when our MAC address is defined afterwards (e.g. in vm creation)
    return false if mac.blank? || hostname.blank?
    return false unless dhcp?

    if dhcp_record && dhcp_record.conflicting? && (!overwrite?)
      failure(_("DHCP records %s already exists") % dhcp_record.conflicts.to_sentence, nil, :conflict)
      return true
    end
    false
  end
end
