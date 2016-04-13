require "resolv"
require "timeout"
require 'ipaddr'

module Net
  module DNS
    autoload :ForwardRecord, "net/dns/forward_record.rb"
    autoload :ARecord,       "net/dns/a_record.rb"
    autoload :AAAARecord,    "net/dns/aaaa_record.rb"
    autoload :ReverseRecord, "net/dns/reverse_record.rb"
    autoload :PTR4Record,    "net/dns/ptr4_record.rb"
    autoload :PTR6Record,    "net/dns/ptr6_record.rb"

    # Looks up the IP or MAC address. Handles the conversion of a DNS miss
    # exception into nil
    # [+query+]: IP or hostname
    # Returns: a new DNS record object, A, AAAA, PTR4 or PTR6 accordingly
    # We query DNS directly, as its faster then to query our own proxy.
    def self.lookup(query, options = {})
      return nil unless query.present?

      proxy = options.fetch(:proxy)
      resolver = options.fetch(:resolver, Resolv::DNS.new)
      ipversion = options.fetch(:ipversion, 4)

      Timeout.timeout(Setting[:dns_conflict_timeout]) do
        ip = IPAddr.new(query) rescue false
        if ip && ip.ipv4?
          n = resolver.getname(query).to_s
          i = query
          t = "PTR"
        elsif ip && ip.ipv6?
          n = resolver.getname(query).to_s
          i = query
          t = "PTR6"
        elsif ipversion == 6
          i = resolver.getresource(query, Resolv::DNS::Resource::IN::AAAA).address.to_s
          n = query
          t = "AAAA"
        else
          i = resolver.getresource(query, Resolv::DNS::Resource::IN::A).address.to_s
          n = query
          t = "A"
        end

        attrs = { :hostname => n, :ip => i, :resolver => resolver, :proxy => proxy }

        case t
          when "A"
            ARecord.new attrs
          when "AAAA"
            AAAARecord.new attrs
          when "PTR"
            PTR4Record.new attrs
          when "PTR6"
            PTR6Record.new attrs
        end
      end
    rescue Resolv::ResolvError, SocketError
      nil
    rescue Timeout::Error => e
      raise Net::Error, e
    end

    class Record < Net::Record
      attr_accessor :ip, :resolver, :type, :ipversion

      def initialize(opts = { })
        super(opts)
        self.resolver ||= Resolv::DNS.new
      end

      def destroy
        logger.info "Delete the DNS #{type} record for #{self}"
      end

      def create
        raise "Must define a hostname" if hostname.blank?
        logger.info "Add DNS #{type} record for #{self}"
      end

      def attrs
        raise "Abstract class"
      end

      def dns_lookup(ip_or_name)
        DNS.lookup(ip_or_name, :proxy => proxy, :resolver => resolver, :ipversion => ipversion)
      end

      protected

      def generate_conflict_error
        logger.warn "Conflicting DNS #{type} record for #{self} detected"
        e          = Net::Conflict.new
        e.type     = "dns"
        e.expected = to_s
        e.actual   = conflicts
        e.message  = "DNS conflict detected - expected #{self}, found #{conflicts.map(&:to_s).join(', ')}"
        e
      end
    end
  end
end
