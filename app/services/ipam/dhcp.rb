module IPAM
  class Dhcp < Base
    delegate :dhcp, :dhcp_proxy, :to => :subnet
    def suggest_ip
      return unless subnet.dhcp?
      # we have DHCP proxy so asking it for free IP
      logger.debug "Asking #{dhcp.url} for free IP"
      ip = dhcp_proxy.unused_ip(subnet, mac)["ip"]
      logger.debug("Found #{ip}")
      ip
    rescue => e
      logger.warn "Failed to fetch a free IP from proxy #{dhcp.name} (#{dhcp.url}): #{e}"
      errors.add(:subnet, _('Failed to fetch a free IP from proxy %{proxy}: %{message}') % {:message => e, :proxy => "#{dhcp.name} (#{dhcp.url})"})
      nil
    end
  end
end
