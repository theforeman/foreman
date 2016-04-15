module IPAM
  class Eui64 < Base
    def suggest_ip
      logger.debug("Suggesting ip for #{self} based on mac '#{mac}' (EUI-64).")
      return unless mac.present? && subnet.network.present? && subnet.cidr.present?
      raise Foreman::Exception.new(N_("Prefix length must be /64 or less to use EUI-64")) if subnet.cidr > 64
      ip = mac_to_ip(mac)
      logger.debug("Generated #{ip}")
      ip
    end

    private

    def mac_to_ip(mac)
      # cleanup MAC address
      mac.gsub!(/[\.\:\-]/, '')

      # separate the 48-bit MAC address into two 24-bits
      oui = mac.slice(0..5)
      ei = mac.slice(6..11)

      # insert 0xFFFE between the two parts
      eui64 = (oui + 'fffe' + ei).to_i(16)

      # invert universal/local bit
      suffix = eui64 ^ 0x0200000000000000

      # convert network to integer
      prefix = IPAddr.new(subnet.network, Socket::AF_INET6).to_i

      # calculate ip based on prefix and EUI-64
      IPAddr.new(prefix | suffix, Socket::AF_INET6).to_s
    end
  end
end
