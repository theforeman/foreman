module Net::DHCP
  class Subnet
    attr_reader :network, :netmask, :options, :routers, :reservations, :leases

    def initialize(options)
      options.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
  end
end