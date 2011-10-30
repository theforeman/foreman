module Orchestration::DHCP
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      after_validation :queue_dhcp
      before_destroy :queue_dhcp_destroy
      validate :ip_belongs_to_subnet?, :valid_jumpstart_model
    end
  end

  module InstanceMethods

    def dhcp?
      !subnet.nil? and subnet.dhcp? and errors.empty?
    end

    def sp_dhcp?
      !sp_subnet.nil? and sp_subnet.dhcp? and errors.empty?
    end

    def dhcp_record
      return unless dhcp?
      @dhcp_record ||= jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    def sp_dhcp_record
      return unless sp_dhcp?
      @sp_dhcp_record ||= Net::DHCP::Record.new sp_dhcp_attrs
    end

    protected

    def set_dhcp
      dhcp_record.create
    end

    def set_sp_dhcp
      sp_dhcp_record.create
    end

    def del_dhcp
      dhcp_record.destroy
    end

    def del_sp_dhcp
      sp_dhcp_record.destroy
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

      bs = tftp.bootServer
      if bs.blank?
        # trying to guess out tftp next server based on the smart proxy hostname
        bs = URI.parse(subnet.tftp.url).host if respond_to?(:tftp?) and tftp?
      end
      return bs unless bs.blank?
      failure "Unable to determine the host's boot server. The DHCP smart proxy failed to provide this information and this subnet is not provided with TFTP services."
    rescue => e
      failure "failed to detect boot server: #{e}"
    end

    def queue_dhcp
      return unless dhcp? and errors.empty?
      new_record? ? queue_dhcp_create : queue_dhcp_update
    end

    def queue_dhcp_create
      queue.create(:name   => "DHCP Settings for #{self}", :priority => 10,
                   :action => [self, :set_dhcp])
      queue.create(:name   => "DHCP Settings for #{sp_name}", :priority => 15,
                   :action => [self, :set_sp_dhcp]) if sp_dhcp?
    end

    def queue_dhcp_update
      queue.create(:name => "DHCP Settings for #{old}", :priority => 5,
                   :action => [old, :del_dhcp]) if old.dhcp? and dhcp_update_required?
      queue.create(:name   => "DHCP Settings for #{old.sp_name}", :priority => 5,
                   :action => [old, :del_sp_dhcp]) if old.sp_dhcp? and sp_dhcp_update_required?
      queue_dhcp_create if dhcp_update_required?
    end

    # do we need to update our dhcp reservations
    def dhcp_update_required?
      # IP Address / name changed
      return true if (old.ip != ip) or (old.name != name) or (old.mac != mac)
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
      return true if old.sp_valid? and ((old.sp_name != sp_name) or (old.sp_mac != sp_mac) or (old.sp_ip != sp_ip))
      false
    end

    def queue_dhcp_destroy
      return unless dhcp? and errors.empty?
      queue.create(:name   => "DHCP Settings for #{self}", :priority => 5,
                   :action => [self, :del_dhcp])
      queue.create(:name   => "DHCP Settings for #{sp_name}", :priority => 5,
                   :action => [self, :del_sp_dhcp]) if sp_valid?
      true
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
      errors.add :model, "Has an unknown vendor class" if model.vendor_class.empty?
      false
    end

    def proxy_for_host
      subnet.dhcp_proxy
    end

    def proxy_for_sp
      sp_subnet.dhcp_proxy
    end
  end
end
