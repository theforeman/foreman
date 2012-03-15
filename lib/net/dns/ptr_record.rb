module Net
  module DNS
    class PTRRecord < DNS::Record
      def initialize opts = { }
        super opts
        @type = "PTR"
      end

      def to_s
        "#{ip}/#{hostname}"
      end

      def destroy
        super
        proxy.delete(to_arpa)
      end

      def create
        super
        proxy.set attrs
      rescue RestClient::Conflict
        raise generate_conflict_error
      end

      # Returns an array of record objects which are conflicting with our own
      def conflicts
        @conflicts ||= [dns_lookup(ip)].delete_if{|c| c == self}.compact
      end

      # Verifies that a record already exists on the dns server
      def valid?
        logger.debug "Fetching DNS reservation for #{to_s}"
        self == dns_lookup(ip)
      end

      def a
        dns_lookup(hostname)
      end

      def attrs
        { :fqdn => hostname, :value => to_arpa, :type => type }
      end

      private
      # Returns: String containing the ip in the in-addr.arpa zone
      def to_arpa
        ip.split(/\./).reverse.join(".") + ".in-addr.arpa"
      end

    end
  end
end