module Net
  module Validations

    IP_REGEXP  = /^(\d{1,3}\.){3}\d{1,3}$/
    MAC_REGEXP = /^([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}$/i
    class Error < RuntimeError;
    end

    # validates the ip address
    def validate_ip ip
      raise Error, "Invalid IP Address #{ip}" unless (ip =~ IP_REGEXP)
      ip
    end

    # validates the mac
    def validate_mac mac
      raise Error, "Invalid MAC #{mac}" unless (mac =~ MAC_REGEXP)
      mac
    end

    def validate_network network
      begin
        validate_ip(network)
      rescue Error
        raise Error, "Invalid Network #{network}"
      end
      network
    end

    # ensures that the ip address does not contain any leading spaces or invalid strings
    def self.normalize_ip ip
      return unless ip.present?
      ip.split(".").map(&:to_i).join(".")
    end

    def self.normalize_mac mac
      return unless mac.present?
      m = mac.downcase
      case m
        when /[a-f0-9]{12}/
          m.gsub(/(..)/) { |mh| mh + ":" }[/.{17}/]
        when /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
          m.split(":").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
      end
    end
  end
end
