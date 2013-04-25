module FogExtensions
  module Ovirt
    module Server

      def state
        status
      end

      def interfaces_attributes=(attrs); end

      def volumes_attributes=(attrs);  end

    end
  end
end