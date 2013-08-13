module FogExtensions
  module Google
    module Server
      def flavor_id
        machine_type
      end

      def pretty_machine_type
        machine_type.split('/')[-1]
      end

      def image_id
        image_name
      end

      def network
      end
    end
  end
end
