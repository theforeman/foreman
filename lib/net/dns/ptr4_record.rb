module Net
  module DNS
    class PTR4Record < DNS::ReverseRecord
      def initialize(opts = {})
        super(opts)
        self.ip = Validations.normalize_ip(ip)
        Validations.validate_ip!(ip)
        self.ipfamily = Socket::AF_INET
      end

      def self.human(count = 1)
        n_('Reverse IPv4 DNS record', 'Reverse IPv4 DNS records', count)
      end

      private

      # Returns: String containing the ip in the in-addr.arpa zone
      def to_arpa
        IPAddr.new(ip).reverse
      end
    end
  end
end
