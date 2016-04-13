require 'ipaddr'
require 'socket'

module Net
  module Validations
    IP_REGEXP  ||= /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\z/
    MAC_REGEXP ||= /\A([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}\z/i
    MAC_REGEXP_64BIT ||= /\A([a-f0-9]{1,2}:){19}[a-f0-9]{1,2}\z/i
    HOST_REGEXP ||= /\A(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\z/
    MASK_REGEXP ||= /\A((255.){3}(0|128|192|224|240|248|252|254))|((255.){2}(0|128|192|224|240|248|252|254).0)|(255.(0|128|192|224|240|248|252|254)(.0){2})|((128|192|224|240|248|252|254)(.0){3})\z/

    class Error < RuntimeError
    end

    class << self
      include Net::Validations
    end

    def valid_mac?(mac)
      return false if mac.nil?

      case mac.size
      when 17
        return true if (mac =~ MAC_REGEXP)
      when 59
        return true if (mac =~ MAC_REGEXP_64BIT)
      end

      false
    end

    module_function :valid_mac?

    # validates an IPv4 address
    def validate_ip(ip)
      return false unless ip.present?
      IPAddr.new(ip, Socket::AF_INET) rescue return false
      true
    end

    # validates an IPv4 address and raises an error
    def validate_ip! ip
      raise Error, "Invalid IP Address #{ip}" unless validate_ip(ip)
      ip
    end

    # validates an IPv6 address
    def validate_ip6 ip
      return false unless ip.present?
      IPAddr.new(ip, Socket::AF_INET6) rescue return false
      true
    end

    # validates an IPv6 address and raises an error
    def validate_ip6! ip
      raise Error, "Invalid IPv6 Address #{ip}" unless validate_ip6(ip)
      ip
    end

    def validate_mask(mask)
      raise Error, "Invalid Subnet Mask #{mask}" unless (mask =~ MASK_REGEXP)
      mask
    end

    # validates the mac
    def validate_mac(mac)
      raise Error, "Invalid MAC #{mac}" unless valid_mac? mac
      mac
    end

    # validates the hostname
    def validate_hostname(hostname)
      raise Error, "Invalid hostname #{hostname}" unless (hostname =~ HOST_REGEXP)
      hostname
    end

    def validate_network(network)
      validate_ip(network) || raise(Error, "Invalid Network #{network}")
      network
    end

    # ensures that the ip address does not contain any leading spaces or invalid strings
    def normalize_ip(ip)
      return unless ip.present?
      return ip unless ip =~ IP_REGEXP
      ip.split(".").map(&:to_i).join(".")
    end

    # return the most efficient form of a v6 address
    def normalize_ip6 ip
      return ip unless ip.present?
      IPAddr.new(ip, Socket::AF_INET6).to_s rescue ip
    end

    def normalize_mac(mac)
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
          raise ArgumentError, "'#{mac}' is not a valid MAC address"
      end
    end

    def self.normalize_hostname(hostname)
      hostname.downcase! if hostname.present?
      hostname
    end
  end
end
