module NicIpRequired
  class Ipv6 < Base
    def initialize(opts = {})
      super
      @subnet = nic.subnet6
      @field = :ip6
      @other_field = :ip
    end
  end
end
