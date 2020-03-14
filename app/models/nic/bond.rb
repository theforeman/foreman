module Nic
  class Bond < Managed
    include Nic::WithAttachedDevices

    attr_exportable :mode, :bond_options

    MODES = %w(balance-rr active-backup balance-xor broadcast 802.3ad balance-tlb balance-alb)
    validates :mode, :presence => true, :inclusion => { :in => MODES }

    def add_slave(identifier)
      add_device(identifier)
    end

    def remove_slave(identifier)
      remove_device(identifier)
    end

    def self.humanized_name
      N_('Bond')
    end
  end

  Base.register_type(Bond)
end
