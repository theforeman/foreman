module FogExtensions
  module Google
    module Flavor
      extend ActiveSupport::Concern

      def id
        name
      end
    end
  end
end
