module FogExtensions
  module Openstack
    module Core
      extend ActiveSupport::Concern

      private

      def authenticate
        super
        if @openstack_identity_public_endpoint || @openstack_management_url
          @identity_connection = Fog::Core::Connection.new(
            @openstack_identity_public_endpoint || @openstack_management_url,
            false, @connection_options)
        end
      end
    end
  end
end
