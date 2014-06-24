module FogExtensions
  module Google
    module Image
      extend ActiveSupport::Concern

      def id
        name
      end
    end
  end
end
