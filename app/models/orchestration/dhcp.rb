module Orchestration::DHCP
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      after_validation :queue_dhcp
      before_destroy :queue_dhcp_destroy
      validate :ip_belongs_to_subnet?
    end
  end

  module InstanceMethods

    def dhcp?
      name.present? and ip.present? and !subnet.nil? and subnet.dhcp? and managed? and capabilities.include?(:build)
    end

    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    protected

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
      # if we don't manage tftp at all, we dont create a next-server entry.
      return unless tftp?

      # first try to ask our TFTP server for its boot server
      bs = tftp.bootServer
      # if that failed, trying to guess out tftp next server based on the smart proxy hostname
      bs ||= URI.parse(subnet.tftp.url).host
      # now convert it into an ip address (see http://theforeman.org/issues/show/1381)
      return to_ip_address(bs) if bs.present?

      failure _("Unable to determine the host's boot server. The DHCP smart proxy failed to provide this information and this subnet is not provided with TFTP services.")
    rescue => e
      failure _("failed to detect boot server: %s") % e
    end

    private

    # returns a hash of dhcp record settings
    def dhcp_attrs
      return unless dhcp?
      dhcp_attr = { :name => name, :filename => operatingsystem.boot_filename(self),
                    :ip => ip, :mac => mac, :hostname => name, :proxy => subnet.dhcp_proxy,
                    :network => subnet.network, :nextServer => boot_server }

      if jumpstart?
        jumpstart_arguments = os.jumpstart_params self, model.vendor_class
        dhcp_attr.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
      dhcp_attr
    end

    def queue_dhcp
      return unless (dhcp? or (old and old.dhcp?)) and orchestration_errors?
      queue_remove_dhcp_conflicts if dhcp_conflict_detected?
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
      # IP Address / name changed
      return true if ((old.ip != ip) or (old.name != name) or (old.mac != mac) or (old.subnet != subnet))
      # Handle jumpstart
      #TODO, abstract this way once interfaces are fully used
      if self.kind_of?(Host::Base) and jumpstart?
        if !old.build? or (old.medium != medium or old.arch != arch) or
            (os and old.os and (old.os.name != os.name or old.os != os))
            return true
        end
      end
      false
    end

    def queue_dhcp_destroy
      return unless dhcp? and errors.empty?
      queue.create(:name   => _("Remove DHCP Settings for %s") % self, :priority => 5,
                   :action => [self, :del_dhcp])
      true
    end

    def queue_remove_dhcp_conflicts
      return unless dhcp? and errors.any? and errors.are_all_conflicts?
      return unless overwrite?
      logger.debug "Scheduling DHCP conflicts removal"
      queue.create(:name   => _("DHCP conflicts removal for %s") % self, :priority => 5,
                   :action => [self, :del_dhcp_conflicts]) if dhcp_record and dhcp_record.conflicting?
    end

    def ip_belongs_to_subnet?
      return if subnet.nil? or ip.nil?
      return unless dhcp?
      unless subnet.contains? ip
        errors.add(:ip, _("Does not match selected Subnet"))
        return false
      end
    rescue
      # probably an invalid ip / subnet were entered
      # we let other validations handle that
    end

    def dhcp_conflict_detected?
      # we can't do any dhcp based validations when our MAC address is defined afterwards (e.g. in vm creation)
      return false if mac.blank? or name.blank?

      # This is an expensive operation and we will only do it if the DNS validation failed. This will ensure
      # that we report on both DNS and DHCP conflicts when we offer to remove collisions. It retrieves and
      # caches the conflicting records so we must always do it when overwriting
      return false unless (errors.any? and errors.are_all_conflicts?) or overwrite?

      return false unless dhcp?
      status = true
      status = failure(_("DHCP records %s already exists") % dhcp_record.conflicts.to_sentence, nil, :conflict) if dhcp_record and dhcp_record.conflicting?
      overwrite? ? errors.are_all_conflicts? : status
    end

  end
end
