module NicIpRequired
  class Ipv4 < Base
    def initialize(opts = {})
      super
      @subnet = nic.subnet
      @field = :ip
      @other_field = :ip6
    end
  end
end
