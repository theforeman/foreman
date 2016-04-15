module IPAM
  class Db < Base
    def suggest_ip
      # Foreman manages reservations internally
      logger.debug "Trying to find free IP for subnet in internal DB"
      subnet_range = IPAddr.new("#{subnet.network}/#{subnet.mask}", subnet.family).to_range
      from = subnet.from.present? ? IPAddr.new(subnet.from) : subnet_range.first(2).last
      to = subnet.to.present? ? IPAddr.new(subnet.to) : IPAddr.new(subnet_range.last.to_i - 2, subnet.family)
      (from..to).each do |address|
        ip = address.to_s
        if !subnet.known_ips.include?(ip) && !excluded_ips.include?(ip)
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
