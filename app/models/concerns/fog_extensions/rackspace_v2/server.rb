module FogExtensions
  module RackspaceV2
    module Server
      extend ActiveSupport::Concern

      def vm_description
        flavor.name
      end

      def ip_addresses
        [public_ip_address, private_ip_address].flatten.select(&:present?)
      end
    end
  end
end
