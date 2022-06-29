module IPAM
  class DHCP < Base
    delegate :dhcp, :dhcp_proxy, :to => :subnet
    def suggest_ip
      unless subnet.dhcp?
        message = N_("Unable to suggest IP: subnet %s don't have a DHCP proxy associated, a proxy is not in subnets organization or IPAM is not set to DHCP") % subnet.name
        logger.info message
        errors.add(:subnet, _(message))
        return
      end
      # we have DHCP proxy so asking it for free IP
      logger.debug "Asking #{dhcp.url} for free IP"
      ip = dhcp_proxy.unused_ip(subnet, mac)["ip"]
      logger.debug("Found #{ip}")
      ip
    rescue => e
      message = N_('Failed to fetch a free IP from proxy %{proxy}: %{message}') % {:message => e, :proxy => "#{dhcp.name} (#{dhcp.url})"}
      logger.warn "#{message}: #{e}"
      errors.add(:subnet, _(message))
      nil
    end
  end
end
