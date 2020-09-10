module FogExtensions
  module Google
    module MachineType
      extend ActiveSupport::Concern

      def id
        name
      end
    end
  end
end
