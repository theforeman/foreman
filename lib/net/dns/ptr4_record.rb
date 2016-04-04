module Net
  module DNS
    class PTR4Record < DNS::ReverseRecord
      def initialize(opts = { })
        super opts
        self.ip = validate_ip! self.ip
        self.ipversion = 4
      end

      private

      # Returns: String containing the ip in the in-addr.arpa zone
      def to_arpa
        ip.split(/\./).reverse.join(".") + ".in-addr.arpa"
      end
    end
  end
end
