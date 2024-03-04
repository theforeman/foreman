module IPAM
  class ExternalIPAM < Base
    delegate :external_ipam_proxy, :to => :subnet

    def suggest_ip
      logger.debug("Obtaining next available IP from IPAM for subnet #{@subnet.network_address}")
      next_ip = external_ipam_proxy.next_ip(@subnet.network_address, mac, @subnet.externalipam_group)
      logger.debug("IPAM returned #{next_ip} as the next available IP in subnet #{@subnet.network_address}")
      next_ip
    rescue => e
      logger.warn "Failed to fetch the next available IP address from IPAM: #{e}"
      errors.add(:subnet, _(e.message))
      nil
    end

    def suggest_new?
      false
    end
  end
end
