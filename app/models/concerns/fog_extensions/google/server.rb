module FogExtensions
  module Google
    module Server
      extend ActiveSupport::Concern

      delegate :flavors, :to => :service

      def pretty_machine_type
        machine_type.split('/')[-1]
      end

      def image_id
        image_name if disks.present?
      end

      def vm_description
        pretty_machine_type
      end

      def volumes_attributes=(attrs)
      end

      def volumes
        disks
      end

      def vm_ip_address
        external_ip ? public_ip_address : private_ip_address
      end
    end
  end
end
