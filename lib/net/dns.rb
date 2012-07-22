require "resolv"
require "timeout"

module Net
  module DNS
    autoload :ARecord,   "net/dns/a_record.rb"
    autoload :PTRRecord, "net/dns/ptr_record.rb"

    # Looks up the IP or MAC address. Handles the conversion of a DNS miss
    # exception into nil
    # [+query+]: IP or hostname
    # Returns: a new DNS record object, A or PTR accordingly
    # We query DNS directly, as its faster then to query our own proxy.
    def self.lookup query, proxy, resolver = Resolv::DNS.new
      Timeout::timeout(3) do
        if (query =~ Validations::IP_REGEXP)
          n = resolver.getname(query).to_s
          i = query
          t = "PTR"
        else
          i = resolver.getaddress(query).to_s
          n = query
          t = "A"
        end
        attrs = { :hostname => n, :ip => i, :resolver => resolver, :proxy => proxy }
        case t
          when "A"
            ARecord.new attrs
          when "PTR"
            PTRRecord.new attrs
        end
      end
    rescue Resolv::ResolvError, SocketError
      nil
    rescue Timeout::Error => e
      raise Net::Error, e
    end

    class Record < Net::Record
      attr_accessor :ip, :resolver, :type

      def initialize opts={ }
        super(opts)
        self.ip = validate_ip self.ip
        self.resolver ||= Resolv::DNS.new
      end

      def destroy
        logger.info "Delete the DNS #{type} record for #{to_s}"
      end

      def create
        logger.info "Add DNS #{type} record for #{to_s}"
      end

      def attrs
        raise "Abstract class"
      end

      def dns_lookup ip_or_name
        DNS.lookup(ip_or_name, proxy, resolver)
      end

      protected

      def generate_conflict_error
        logger.warn "Conflicting DNS #{type} record for #{to_s} detected"
        e          = Net::Conflict.new
        e.type     = "dns"
        e.expected = to_s
        e.actual   = conflicts
        e.message  = "DNS conflict detected - expected #{to_s}, found #{conflicts.map(&:to_s).join(', ')}"
        e
      end

    end
  end
end
