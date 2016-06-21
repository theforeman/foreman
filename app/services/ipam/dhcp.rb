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
    end

    def used_ips
      (proxy_subnets['leases'] + proxy_subnets['reservations']).collect{|record| record[ip]}
    end

    def usage
      return unless subnet.dhcp?
      dhcp_proxy.subnet_usage(subnet)["used"]
    end

    private

    def proxy_subnets
      @proxy_subnets ||= dhcp_proxy.subnet(subnet.network)
    end
  end
end
