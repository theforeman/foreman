module FogExtensions
  module AWS
    module Flavor
      def to_label
        "#{id} - #{name}"
      end
    end
  end
end