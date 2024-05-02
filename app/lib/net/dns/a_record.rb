module Net
  module DNS
    class ARecord < DNS::ForwardRecord
      def initialize(opts = {})
        super(opts)
        self.ip = Validations.normalize_ip(ip)
        Validations.validate_ip!(ip)
        self.ipfamily = Socket::AF_INET
        @type = "A"
      end

      def self.human(count = 1)
        n_('IPv4 DNS record', 'IPv4 DNS records', count)
      end
    end
  end
end
