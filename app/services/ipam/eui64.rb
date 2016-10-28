module IPAM
  class Eui64 < Base
    def suggest_ip
      logger.debug("Suggesting ip for #{subnet} based on mac '#{mac}' (EUI-64).")
      validate
      return if errors.present?
      return unless mac.present?
      ip = mac_to_ip(mac)
      logger.debug("Generated #{ip}")
      ip
    end

    def suggest_new?
      false
    end

    private

    def validate
      errors.add(:subnet, _("Network can't be blank")) unless subnet.network.present?
      errors.add(:subnet, _("Prefix length can't be blank")) unless subnet.cidr.present?
      errors.add(:subnet, _("Prefix length must be /64 or less to use EUI-64")) if subnet.cidr > 64
    end

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
