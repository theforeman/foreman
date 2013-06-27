module FogExtensions
  module Openstack
    module Server

      extend ActiveSupport::Concern

      included do
        alias_method_chain :security_groups, :no_id
      end

      def to_s
        name
      end

      def tenant
        service.tenants.detect{|t| t.id == tenant_id }
      end

      def flavor_with_object
        service.flavors.get attributes[:flavor]['id']
      end

      def created_at
        Time.parse attributes['created']
      end

      # the original method requires a server ID, however we want to be able to call this method on new instances too
      def security_groups_with_no_id
        return [] if id.nil?

        security_groups_without_no_id
      end

      # dummy place holder for passing down the floating ip network
      def network
      end

      def reset
        reboot('HARD')
      end

    end
  end
end