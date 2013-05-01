module FogExtensions
  module AWS
    module Server
      extend ActiveSupport::Concern
      def to_s
        tags["Name"] || identity
      end

      def name
        to_s
      end

      def dns
         dns_name || private_dns_name
      end

    end
  end
end
