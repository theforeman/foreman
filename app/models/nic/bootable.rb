module Nic
  class Bootable < Managed

    delegate :tftp?, :tftp, :to => :subnet
    delegate :jumpstart?, :build?, :to => :host

    # ensure that we can only have one bootable interface
    validates_uniqueness_of :type, :scope => :host_id, :message => "Only one bootable interface is allowed"

    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= host.jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    protected

    def dhcp_attrs
      attrs = super.merge({
                            :filename   => host.operatingsystem.boot_filename(host),
                            :nextServer => boot_server
                          })
      # Are we booting SPARC solaris?
      if host.jumpstart?
        jumpstart_arguments = host.os.jumpstart_params host, host.model.vendor_class
        attrs.merge! jumpstart_arguments unless jumpstart_arguments.empty?
      end
      attrs
    end

  end
end