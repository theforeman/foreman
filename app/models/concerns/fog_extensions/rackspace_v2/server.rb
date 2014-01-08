module FogExtensions
  module RackspaceV2
    module Server
      extend ActiveSupport::Concern

      def vm_description
        flavor.name
      end

    end
  end
end
