module IPAM
  # Internal DB IPAM returning all IPs in natural order
  class Db < Base
    def suggest_ip
      subnet_range.each do |address|
        ip = address.to_s
        if !excluded_ips.include?(ip) && !subnet.known_ips.include?(ip) && !is_ip_blocked?(ip)
          logger.debug("Found IP #{ip}, blocking it for the next #{block_ip_minutes} minutes")
          block_ip(ip)
          return ip
        end
      end
      logger.debug("Not suggesting IP Address for #{subnet} as no free IP found in our DB")
      errors.add(:subnet, _('no free IP could be found in our DB'))
      nil
    end
  end
end
