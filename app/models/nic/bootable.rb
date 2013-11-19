module Nic
  class Bootable < Managed

    delegate :tftp?, :tftp, :to => :subnet
    delegate :jumpstart?, :build?, :to => :system

    # ensure that we can only have one bootable interface
    validates :type, :uniqueness => {:scope => :system_id, :message => N_("Only one bootable interface is allowed")}

    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= system.jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    protected

    def dhcp_attrs
      attrs = super.merge({
                            :filename   => system.operatingsystem.boot_filename(system),
                            :nextServer => boot_server
                          })
      # Are we booting SPARC solaris?
      if system.jumpstart?
        jumpstart_arguments = system.os.jumpstart_params system, system.model.vendor_class
        attrs.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
      attrs
    end

  end
end
