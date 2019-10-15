module IPAM
  class ExternalIpam < Base
    delegate :external_ipam_proxy, :to => :subnet

    def suggest_ip
      if self.mac.nil?
        errors.add(:mac, "You must specify a MAC address before selecting the External IPAM subnet")
        return nil
      end

      logger.debug "Obtaining next available IP from IPAM for subnet #{@subnet.network_address}"
      response = external_ipam_proxy.next_ip(@subnet, self.mac)

      if response.key?('error')
        errors.add(:subnet, response['error'])
        nil
      else
        next_ip = response["data"]
        logger.debug("IPAM returned #{next_ip} as the next available IP in subnet #{@subnet.network_address}")
        next_ip
      end
    rescue => e
      logger.warn "Failed to fetch the next available IP address from IPAM: #{e}"
      errors.add(:subnet, _('Failed to fetch the next available IP address from IPAM %{message}') % {:message => e})
      nil
    end

    def suggest_new?
      false
    end
  end
end
