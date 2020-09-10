module Net
  module DNS
    class PTR6Record < DNS::ReverseRecord
      def initialize(opts = {})
        super(opts)
        self.ip = Validations.normalize_ip6(ip)
        Validations.validate_ip6!(ip)
        self.ipfamily = Socket::AF_INET6
      end

      def self.human(count = 1)
        n_('Reverse IPv6 DNS record', 'Reverse IPv6 DNS records', count)
      end

      private

      # Returns: String containing the ip in the ip6.arpa zone
      def to_arpa
        IPAddr.new(ip).ip6_arpa
      end
    end
  end
end
