module FogExtensions
  module AWS
    module Flavor
      extend ActiveSupport::Concern
      def to_label
        "#{id} - #{name}"
      end
    end
  end
end
