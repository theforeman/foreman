module FogExtensions
  module DigitalOcean
    module Server
      extend ActiveSupport::Concern

      def vm_description
        flavor.try(:name)
      end

      def flavor
        requires :flavor_id
        @flavor ||= service.flavors.get(flavor_id.to_i)
      end

      def image
        requires :image_id
        @image ||= service.images.get(image_id)
      end

      def region
        requires :region_id
        @region ||= service.regions.get(region_id)
      end

      def ip_addresses
        mage[public_ip_address, private_ip_address].flatten.select(&:present?)
      end

    end
  end
end
