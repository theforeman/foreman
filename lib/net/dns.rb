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

      proxy = options.fetch(:proxy, nil)
      resolver = options.fetch(:resolver, Resolv::DNS.new)
      ipfamily = options.fetch(:ipfamily, Socket::AF_INET)
      resolver.timeouts = options.fetch(:timeout, Setting[:dns_timeout])

      ipquery = IPAddr.new(query) rescue nil
      if ipquery&.ipv4?
        hostname = resolver.getname(query).to_s
        ip = query
        type = "PTR4"
      elsif ipquery&.ipv6?
        hostname = resolver.getname(query).to_s
        ip = query
        type = "PTR6"
      elsif ipfamily == Socket::AF_INET6
        ip = resolver.getresource(query, Resolv::DNS::Resource::IN::AAAA).address.to_s
        hostname = query
        type = "AAAA"
      else
        ip = resolver.getresource(query, Resolv::DNS::Resource::IN::A).address.to_s
        hostname = query
        type = "A"
      end

      attrs = { :hostname => hostname, :ip => ip, :resolver => resolver, :proxy => proxy }

      case type
        when "A"
          ARecord.new attrs
        when "AAAA"
          AAAARecord.new attrs
        when "PTR4"
          PTR4Record.new attrs
        when "PTR6"
          PTR6Record.new attrs
      end
    rescue Resolv::ResolvError, SocketError
      nil
    end

    class Record < Net::Record
      attr_accessor :ip, :resolver, :type, :ipfamily

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

      def dns_lookup(ip_or_name, ipfamily = nil)
        DNS.lookup(ip_or_name, :proxy => proxy, :resolver => resolver, :ipfamily => ipfamily || self.ipfamily)
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
