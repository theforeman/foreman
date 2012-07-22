module FogExtensions
  module Openstack
    module Flavor
      def to_label
        "#{id} - #{name}"
      end

      def to_s
        name
      end
    end
  end
end