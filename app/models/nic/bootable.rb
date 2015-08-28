module Nic
  class Bootable < Managed
    delegate :tftp?, :tftp, :to => :subnet
    delegate :jumpstart?, :build?, :to => :host

    # ensure that we can only have one bootable interface
    validates :type, :uniqueness => {:scope => :host_id, :message => N_("Only one bootable interface is allowed")}

    register_to_enc_transformation :type, ->(type) { type.constantize.humanized_name }

    def self.human_name
      N_('Bootable')
    end
  end
end
