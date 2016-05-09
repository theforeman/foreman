module IPAM
  class Db < Base
    def suggest_ip
      # Foreman manages reservations internally
      logger.debug "Trying to find free IP for subnet in internal DB"
      self.range.each do |address|
        ip = address.to_s
        if !subnet.known_ips.include?(ip) && !excluded_ips.include?(ip)
          logger.debug("Found #{ip}")
          return(ip)
        end
      end
      logger.debug("Not suggesting IP Address for #{self} as no free IP found in our DB")
      nil
    end
  end
end
