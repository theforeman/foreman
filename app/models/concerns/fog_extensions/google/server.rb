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

    end
  end
end
