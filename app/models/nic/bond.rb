module Nic
  class Bond < Managed
    include Nic::WithAttachedDevices

    MODES     = %w(balance-rr active-backup balance-xor broadcast 802.3ad balance-tlb balance-alb)
    validates :mode, :presence => true, :inclusion => { :in => MODES }

    def add_slave(identifier)
      self.add_device(identifier)
    end

    def remove_slave(identifier)
      self.remove_device(identifier)
    end

    def self.humanized_name
      N_('Bond')
    end

    private

    def enc_attributes
      @enc_attributes ||= (super + %w(mode bond_options))
    end
  end

  Base.register_type(Bond)
end
