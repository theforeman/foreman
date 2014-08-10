module FogExtensions
  module Google
    module Server
      extend ActiveSupport::Concern

      def pretty_machine_type
        machine_type.split('/')[-1]
      end

      def flavors
        service.flavors
      end

      def image_id
        image_name unless disks.nil?
      end

      def vm_description
        pretty_machine_type
      end

    end
  end
end
