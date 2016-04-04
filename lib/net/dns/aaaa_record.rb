module Net
  module DNS
    class AAAARecord < DNS::ForwardRecord
      def initialize(opts = { })
        super opts
        self.ip = validate_ip6! self.ip
        self.ipversion = 6
        @type = "AAAA"
      end
    end
  end
end

