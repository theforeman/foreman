module Net
  module Validations

    IP_REGEXP  = /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\z/
    MAC_REGEXP = /\A([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}\z/i
    HOST_REGEXP = /\A(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\z/

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

    # validates the hostname
    def validate_hostname hostname
      raise Error, "Invalid Hostname #{hostname}" unless (hostname =~ HOST_REGEXP)
      hostname
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
        when /([a-f0-9]{1,2}-){5}[a-f0-9]{1,2}/
          m.split("-").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
      end
    end

   def self.normalize_hostname hostname
     hostname.downcase! if hostname.present?
     hostname
   end
  end
end
