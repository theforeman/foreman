module IPAM
  # Internal DB IPAM returning all IPs in natural order
  class Db < Base
    def suggest_ip
      subnet_range.each do |address|
        ip = address.to_s
        if !excluded_ips.include?(ip) && !subnet.known_ips.include?(ip)
          logger.debug("Found #{ip}")
          return ip
        end
      end
      logger.debug("Not suggesting IP Address for #{subnet} as no free IP found in our DB")
      errors.add(:subnet, _('no free IP could be found in our DB'))
      nil
    end
  end
end
