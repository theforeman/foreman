module Net
  module DNS
    class PTR4Record < DNS::ReverseRecord
      def initialize(opts = { })
        super opts
        self.ip = Validations.validate_ip! self.ip
        self.ipfamily = Socket::AF_INET
      end

      private

      # Returns: String containing the ip in the in-addr.arpa zone
      def to_arpa
        IPAddr.new(ip).reverse
      end
    end
  end
end
