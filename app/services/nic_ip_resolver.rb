# converts a name into ip address using DNS in the interface scope
# if we are managing DNS, we can query the correct DNS server
# otherwise, use normal systems dns settings to resolv
class NicIpResolver
  attr_accessor :nic

  delegate :logger, :to => :Rails
  delegate :dns_record, :domain, :to => :nic

  def initialize(opts)
    @nic = opts.fetch(:nic)
  end

  def to_ip_address(name_or_ip)
    return name_or_ip if name_or_ip =~ Net::Validations::IP_REGEXP
    if dns_record(:ptr4)
      lookup = dns_record(:ptr4).dns_lookup(name_or_ip)
      return lookup.ip unless lookup.nil?
    end
    # fall back to normal dns resolution
    domain.resolver.getaddress(name_or_ip).to_s
  rescue => e
    logger.warn "Unable to find IP address for '#{name_or_ip}': #{e}"
    raise ::Foreman::WrappedException.new(e, N_("Unable to find IP address for '%s'"), name_or_ip)
  end
end
