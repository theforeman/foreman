module Net
  module DNS
    class PTR6Record < DNS::ReverseRecord
      def initialize(opts = { })
        super opts
        self.ip = validate_ip6! self.ip
        self.ipversion = 6
      end

      private

      # Returns: String containing the ip in the ip6.arpa zone
      def to_arpa
        IPAddr.new(ip).ip6_arpa
      end
    end
  end
end
