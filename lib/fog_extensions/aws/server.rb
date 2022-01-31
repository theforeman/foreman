module FogExtensions
  module AWS
    module Server
      extend ActiveSupport::Concern
      extend Fog::Attributes::ClassMethods

      attr_accessor :managed_ip

      def load_tags
        list_of_tags = tags
        return list_of_tags unless tags.present?

        if list_of_tags.is_a?(Hash)
          service.tags.all('key' => list_of_tags.keys, 'resource-id' => identity)
        else
          list_of_tags
        end
      end

      # HACK: for tags form to work properly
      def tags_attributes=(tags)
      end

      def to_s
        tags.try(:[], 'Name') || identity
      end

      def name
        to_s
      end

      def dns
        dns_name || private_dns_name
      end

      def vm_ip_address
        (managed_ip == 'private') ? private_ip_address : public_ip_address
      end

      def poweroff
        stop(true)
      end

      def reset
        poweroff && start
      end

      def vm_description
        flavor.to_label
      end

      def ip_addresses
        [public_ip_address, private_ip_address].flatten.select(&:present?)
      end
    end
  end
end
