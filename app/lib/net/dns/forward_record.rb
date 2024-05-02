module Net
  module DNS
    class ForwardRecord < DNS::Record
      def to_s
        "#{hostname}/#{ip}"
      end

      def destroy
        super
        proxy.delete("#{hostname}/#{type}")
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

      # Verifies that a record already exists on the dns server
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
