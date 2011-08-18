module Net
  module Validations

    class Error < RuntimeError; end

    # validates the ip address
    def validate_ip ip
      raise Error, "Invalid IP Address #{ip}" unless (ip =~ /(\d{1,3}\.){3}\d{1,3}/)
      ip
    end

    # validates the mac
    def validate_mac mac
      raise Error, "Invalid MAC #{mac}" unless (mac =~ /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/i)
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

  end
end
