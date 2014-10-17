module Nic
  class Bond < Managed
    SEPARATOR = ','
    MODES     = %w(balance-rr active-backup balance-xor broadcast 802.3ad balance-tlb balance-alb)
    validates :mode, :presence => true, :inclusion => { :in => MODES }
    validates :attached_devices, :format => { :with => /\A[a-z0-9#{SEPARATOR}.:_-]+\Z/ }, :allow_blank => true

    before_save :ensure_virtual

    def virtual
      true
    end
    alias_method :virtual?, :virtual

    def attached_devices=(devices)
      devices = devices.split(SEPARATOR) if devices.is_a?(String)
      super(devices.map { |i| i.downcase.strip }.join(SEPARATOR))
    end

    def attached_devices_identifiers
      attached_devices.split(SEPARATOR)
    end

    def add_slave(identifier)
      self.attached_devices = attached_devices_identifiers.push(identifier).uniq.join(SEPARATOR)
    end

    def remove_slave(identifier)
      self.attached_devices = attached_devices_identifiers.tap { |a| a.delete(identifier) }.join(SEPARATOR)
    end

    def self.humanized_name
      N_('Bond')
    end

    private

    def ensure_virtual
      self.virtual = true
    end

    def enc_attributes
      @enc_attributes ||= (super + %w(mode attached_devices bond_options))
    end
  end

  Base.register_type(Bond)
end
