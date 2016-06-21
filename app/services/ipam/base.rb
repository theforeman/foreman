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

    def used_ips
      subnet.known_ips.select {|ip| range.include?(ip)}
    end

    def usage
      used_ips.count
    end

    def range
      return subnet.to_range unless self.from && self.to
      (self.from..self.to)
    end

    def from
      return IPAddr.new(subnet.from) if subnet.from.present?
      return unless subnet.to_range
      subnet.to_range.first(2).last
    end

    def to
      return IPAddr.new(subnet.to) if subnet.to.present?
      return unless subnet.to_range
      IPAddr.new(subnet.to_range.last.to_i - 1, subnet.family)
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
