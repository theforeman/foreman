module Net
  module DNS
    class AAAARecord < DNS::ForwardRecord
      def initialize(opts = {})
        super(opts)
        self.ip = Validations.normalize_ip6(ip)
        Validations.validate_ip6!(ip)
        self.ipfamily = Socket::AF_INET6
        @type = "AAAA"
      end

      def self.human(count = 1)
        n_('IPv6 DNS record', 'IPv6 DNS records', count)
      end
    end
  end
end
