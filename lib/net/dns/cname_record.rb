module Net
  module DNS
    class CNAMERecord < DNS::Record
      def initialize(opts = { })
        super opts
        @type = "CNAME"
      end

      def to_s
        "#{value}/#{hostname}"
      end

      def destroy
        super
        proxy.delete(hostname)
      end

      def create
        super
        proxy.set attrs
      rescue RestClient::Conflict
        raise generate_conflict_error
      end

      # Returns an array of record objects which are conflicting with our own
      def conflicts
        @conflicts ||= [dns_lookup(hostname)].delete_if{|c| c == self}.compact
      end

      # Verifies that a record already exists on the dns server
      def valid?
        logger.debug "Fetching DNS reservation for #{to_s}"
        dns_lookup(hostname).valid?
      end

      def a
        dns_lookup(hostname)
      end

      def attrs
        { :fqdn => hostname, :value => value, :type => type }
      end
    end
  end
end
