module FogExtensions
  module AWS
    module Server
      def to_s
        tags["Name"] || identity
      end

      def name
        to_s
      end

      def dns
         dns_name || private_dns_name
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
