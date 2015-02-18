module Nic
  class Bootable < Managed
    delegate :tftp?, :tftp, :to => :subnet
    delegate :jumpstart?, :build?, :to => :host

    # ensure that we can only have one bootable interface
    validates :type, :uniqueness => {:scope => :host_id, :message => N_("Only one bootable interface is allowed")}

    register_to_enc_transformation :type, lambda { |type| type.constantize.humanized_name }

    def dhcp_record
      return unless dhcp? or @dhcp_record
      @dhcp_record ||= host.jumpstart? ? Net::DHCP::SparcRecord.new(dhcp_attrs) : Net::DHCP::Record.new(dhcp_attrs)
    end

    def self.human_name
      N_('Bootable')
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
