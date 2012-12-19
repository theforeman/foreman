module Orchestration::DHCP
  extend ActiveSupport::Concern

  included do
    after_validation :queue_dhcp
    before_destroy :queue_dhcp_destroy
    validate :ip_belongs_to_subnet?, :valid_jumpstart_model
  end

  module InstanceMethods

    def dhcp?
      !subnet.nil? and subnet.dhcp? and managed? and capabilities.include?(:build)
    end

    def sp_dhcp?
      sp_valid? and !sp_subnet.nil? and sp_subnet.dhcp?
    end

    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    def sp_dhcp_record
      return unless sp_dhcp? or @sp_dhcp_record
      @sp_dhcp_record ||= Net::DHCP::Record.new sp_dhcp_attrs
    end

    protected

    def set_dhcp
      dhcp_record.create
    end

    def set_dhcp_conflicts
      dhcp_record.conflicts.each{|conflict| conflict.create}
    end

    def set_sp_dhcp
      sp_dhcp_record.create
    end

    def set_sp_dhcp_conflicts
      sp_dhcp_record.conflicts.each{|conflict| conflict.create}
    end

    def del_dhcp
      dhcp_record.destroy
    end

    def del_dhcp_conflicts
      dhcp_record.conflicts.each{|conflict| conflict.destroy}
    end

    def del_sp_dhcp
      sp_dhcp_record.destroy
    end

    def del_sp_dhcp_conflicts
      sp_dhcp_record.conflicts.each{|conflict| conflict.destroy}
    end

    private
    # returns a hash of dhcp record settings
    def dhcp_attrs
      return unless dhcp?
      dhcp_attr = { :name => name, :filename => operatingsystem.boot_filename(self),
                    :ip => ip, :mac => mac, :hostname => name, :proxy => proxy_for_host,
                    :network => subnet.network, :nextServer => boot_server }

      if jumpstart?
        jumpstart_arguments = os.jumpstart_params self, model.vendor_class
        dhcp_attr.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
      dhcp_attr
    end

    # returns a hash of service processor / ilo dhcp record settings
    def sp_dhcp_attrs
      return unless sp_dhcp?
      { :hostname => sp_name, :name => sp_name, :ip => sp_ip, :mac => sp_mac, :proxy => proxy_for_sp, :network => sp_subnet.network }
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

      failure "Unable to determine the host's boot server. The DHCP smart proxy failed to provide this information and this subnet is not provided with TFTP services."
    rescue => e
      failure "failed to detect boot server: #{e}"
    end

    def queue_dhcp
      return unless (dhcp? or (old and old.dhcp?) or sp_dhcp? or (old and old.sp_dhcp?)) and orchestration_errors?
      queue_remove_dhcp_conflicts if dhcp_conflict_detected?
      new_record? ? queue_dhcp_create : queue_dhcp_update
    end

    def queue_dhcp_create
      logger.debug "Scheduling new DHCP reservations"
      queue.create(:name   => "Create DHCP Settings for #{self}", :priority => 10,
                   :action => [self, :set_dhcp]) if dhcp?
      queue.create(:name   => "Create DHCP Settings for #{sp_name}", :priority => 15,
                   :action => [self, :set_sp_dhcp]) if sp_dhcp?
    end

    def queue_dhcp_update
      if dhcp_update_required?
        logger.debug("Detected a changed required for DHCP record")
        queue.create(:name => "Remove DHCP Settings for #{old}", :priority => 5,
                     :action => [old, :del_dhcp]) if old.dhcp?
        queue.create(:name   => "Create DHCP Settings for #{self}", :priority => 9,
                     :action => [self, :set_dhcp]) if dhcp?
      end

      if sp_dhcp_update_required?
        logger.debug("Detected a changed required for BMC DHCP record")
        queue.create(:name   => "Remove DHCP Settings for #{old.sp_name}", :priority => 5,
                     :action => [old, :del_sp_dhcp]) if old.sp_dhcp?
        queue.create(:name   => "Create DHCP Settings for #{sp_name}", :priority => 14,
                     :action => [self, :set_sp_dhcp]) if sp_dhcp?
      end
    end

    # do we need to update our dhcp reservations
    def dhcp_update_required?
      # IP Address / name changed
      return true if ((old.ip != ip) or (old.name != name) or (old.mac != mac) or (old.subnet != subnet))
      # Handle jumpstart
      if jumpstart?
        if !old.build? or (old.medium != medium or old.arch != arch) or
            (os and old.os and (old.os.name != os.name or old.os != os))
            return true
        end
      end
      false
    end

    def sp_dhcp_update_required?
      return true if ((old.sp_name != sp_name) or (old.sp_mac != sp_mac) or (old.sp_ip != sp_ip) or (old.sp_subnet != sp_subnet))
      false
    end

    def queue_dhcp_destroy
      return unless dhcp? and errors.empty?
      queue.create(:name   => "Remove DHCP Settings for #{self}", :priority => 5,
                   :action => [self, :del_dhcp])
      queue.create(:name   => "Remove DHCP Settings for #{sp_name}", :priority => 5,
                   :action => [self, :del_sp_dhcp]) if sp_valid?
      true
    end

    def queue_remove_dhcp_conflicts
      return unless dhcp? and errors.any? and errors.are_all_conflicts?
      return unless overwrite?
      logger.debug "Scheduling DHCP conflicts removal"
      queue.create(:name   => "DHCP conflicts removal for #{self}", :priority => 5,
                   :action => [self, :del_dhcp_conflicts]) if dhcp_record and dhcp_record.conflicting?
      queue.create(:name   => "DHCP conflicts removal for #{sp_name}", :priority => 5,
                   :action => [self, :del_sp_dhcp_conflicts]) if sp_valid? and sp_dhcp and sp_dhcp_record.conflicting?
    end

    def ip_belongs_to_subnet?
      return if subnet.nil? or ip.nil?
      return unless dhcp?
      unless subnet.contains? ip
        errors.add :ip, "Does not match selected Subnet"
        return false
      end
    rescue
      # probably an invalid ip / subnet were entered
      # we let other validations handle that
    end

    def valid_jumpstart_model
      return unless jumpstart?
      errors.add :model_id, "is required for Solaris SPARC deployment" if model.blank?
      errors.add :model_id, "Has an unknown vendor class" if model and model.vendor_class.empty?
      false
    end

    def proxy_for_host
      subnet.dhcp_proxy
    end

    def proxy_for_sp
      sp_subnet.dhcp_proxy
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
      status = failure("DHCP record #{dhcp_record.conflicts[0]} already exists", nil, :conflict) if dhcp_record and dhcp_record.conflicting?
      status &= failure("DHCP record #{sp_dhcp_record.conflicts[0]} already exists", nil, :conflict) if sp_dhcp? and sp_dhcp_record and sp_dhcp_record.conflicting?
      overwrite? ? errors.are_all_conflicts? : status
    end

  end
end
