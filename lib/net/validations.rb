require 'ipaddr'
require 'socket'

module Net
  module Validations
    IP_REGEXP  ||= /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\z/
    MAC_REGEXP ||= /\A([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}\z/i
    MAC_REGEXP_64BIT ||= /\A([a-f0-9]{1,2}:){19}[a-f0-9]{1,2}\z/i
    HOST_REGEXP ||= /\A(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\z/
    MASK_REGEXP ||= /\A((255.){3}(0|128|192|224|240|248|252|254))|((255.){2}(0|128|192|224|240|248|252|254).0)|(255.(0|128|192|224|240|248|252|254)(.0){2})|((128|192|224|240|248|252|254)(.0){3})\z/

    HOST_REGEXP_ERR_MSG = N_("hostname can contain only lowercase letters, numbers, dashes and dots according to RFC921, RFC952 and RFC1123")

    class Error < RuntimeError
    end

    # validates an IPv4 address
    def self.validate_ip(ip)
      return false unless ip.present?
      IPAddr.new(ip, Socket::AF_INET) rescue return false
      true
    end

    # validates an IPv4 address and raises an error
    def self.validate_ip!(ip)
      raise Error, "Invalid IP Address #{ip}" unless validate_ip(ip)
      ip
    end

    # validates an IPv6 address
    def self.validate_ip6(ip)
      return false unless ip.present?
      IPAddr.new(ip, Socket::AF_INET6) rescue return false
      true
    end

    # validates an IPv6 address and raises an error
    def self.validate_ip6!(ip)
      raise Error, "Invalid IPv6 Address #{ip}" unless validate_ip6(ip)
      ip
    end

    # validates a network mask
    def self.validate_mask(mask)
      mask =~ MASK_REGEXP
    end

    # validates a network mask and raises an error
    def self.validate_mask!(mask)
      raise Error, "Invalid Subnet Mask #{mask}" unless validate_mask(mask)
      mask
    end

    # validates the mac
    def self.validate_mac(mac)
      return false if mac.nil?

      case mac.size
      when 17
        return true if (mac =~ MAC_REGEXP)
      when 59
        return true if (mac =~ MAC_REGEXP_64BIT)
      end

      false
    end

    def self.multicast_mac?(mac)
      return false unless validate_mac(mac)

      # Get the first byte
      msb = mac.tr('.:-', '').slice(0..1).to_i(16)

      # Is least significant bit set?
      msb & 0b1 == 1
    end

    def self.broadcast_mac?(mac)
      return false unless validate_mac(mac)
      mac.downcase == 'ff:ff:ff:ff:ff:ff'
    end

    # validates the mac and raises an error
    def self.validate_mac!(mac)
      raise Error, "Invalid MAC #{mac}" unless validate_mac(mac)
      mac
    end

    # validates the hostname
    def self.validate_hostname(hostname)
      hostname =~ HOST_REGEXP
    end

    # validates the hostname and raises an error
    def self.validate_hostname!(hostname)
      raise Error, "Invalid hostname #{hostname}" unless validate_hostname(hostname)
      hostname
    end

    def self.validate_network(network)
      validate_ip(network)
    end

    def self.validate_network!(network)
      raise(Error, "Invalid Network #{network}") unless validate_network(network)
      network
    end

    # ensures that the ip address does not contain any leading spaces or invalid strings
    def self.normalize_ip(ip)
      return unless ip.present?
      return ip unless ip =~ IP_REGEXP
      ip.split(".").map(&:to_i).join(".")
    end

    # return the most efficient form of a v6 address
    def self.normalize_ip6(ip)
      return ip unless ip.present?
      IPAddr.new(ip, Socket::AF_INET6).to_s rescue ip
    end

    def self.normalize_mac(mac)
      return unless mac.present?
      m = mac.downcase
      case m
        when /\A[a-f0-9]{40}\z/
          m.gsub(/(..)/) { |mh| mh + ":" }[/.{59}/]
        when /\A[a-f0-9]{12}\z/
          m.gsub(/(..)/) { |mh| mh + ":" }[/.{17}/]
        when /\A([a-f0-9]{1,2}:){19}[a-f0-9]{1,2}\z/
          m.split(":").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
        when /\A([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}\z/
          m.split(":").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
        when /\A([a-f0-9]{1,2}-){19}[a-f0-9]{1,2}\z/
          m.split("-").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
        when /\A([a-f0-9]{1,2}-){5}[a-f0-9]{1,2}\z/
          m.split("-").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
        else
          raise Error, "'#{mac}' is not a valid MAC address"
      end
    end

    def self.normalize_hostname(hostname)
      hostname.downcase! if hostname.present?
      hostname
    end
  end
end
