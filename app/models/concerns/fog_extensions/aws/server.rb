module FogExtensions
  module AWS
    module Server
      extend ActiveSupport::Concern

      attr_accessor :managed_ip

      def to_s
        tags["Name"] || identity
      end

      def name
        to_s
      end

      def dns
         dns_name || private_dns_name
      end

      def vm_ip_address
        managed_ip == 'private' ? private_ip_address : public_ip_address
      end

      def poweroff
        stop(true)
      end

      def reset
        poweroff &&  start
      end
    end
  end
end
