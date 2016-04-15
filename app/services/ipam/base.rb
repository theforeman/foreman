module IPAM
  class Base
    delegate :logger, :to => :Rails
    attr_accessor :mac, :subnet, :excluded_ips

    def initialize(opts = {})
      @subnet = opts[:subnet]
      @excluded_ips = opts.fetch(:excluded_ips, [])
      @mac = opts.fetch(:mac, nil)

      normalize_mac!
    end

    private

    def normalize_mac!
      return unless self.mac.present?
      self.mac = Net::Validations.normalize_mac(self.mac)
    rescue Net::Validations::Error
      raise Foreman::Exception.new(N_("'%s' is not a valid MAC address.") % self.mac)
    end
  end
end
