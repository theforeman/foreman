module Net
  module DNS
    class ARecord < DNS::Record
      attr_reader :type

      def initialize opts = { }
        super opts
        @type = "A"
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
        @conflicts ||= [dns_lookup(hostname)].delete_if { |c| c == self }.compact
      end

      # Verifies that are record already exists on the dhcp server
      def valid?
        self == dns_lookup(hostname)
      end

      def ptr
        dns_lookup(ip)
      end

      def attrs
        { :fqdn => hostname, :value => ip, :type => type }
      end

    end
  end
end

