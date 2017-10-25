module Net
  module DNS
    class CNAMERecord < DNS::Record
      attr_accessor :host_alias

      def initialize(opts = { })
        super(opts)
        @type = "CNAME"
      end

      def self.human(count = 1)
        n_("CNAME DNS record", "CNAME DNS records", count)
      end

      def to_s
        "#{host_alias}/#{hostname}"
      end

      def destroy
        super
        proxy.delete("#{host_alias}/#{type}")
      end

      def create
        super
        proxy.set attrs
      rescue RestClient::Conflict
        raise generate_conflict_error
      end

      # Returns an array of record objects which are conflicting with our own
      def conflicts
        @conflicts ||= [dns_lookup(host_alias)].delete_if{|c| c == self}.compact
      end

      # Verifies that a already exists on the dns server
      def valid?
        logger.debug "Fetching DNS reservation for #{self}"
        dns_lookup(hostname).valid?
      end

      def a
        dns_lookup(hostname, Socket::AF_INET)
      end

      def aaaa
        dns_lookup(hostname, Socket::AF_INET6)
      end

      def ip
        return a.ip if a
        return aaaa.ip
      end

      def attrs
        { :fqdn => host_alias, :value => hostname, :type => type }
      end
    end
  end
end
