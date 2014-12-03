module FogExtensions
  module Openstack
    module Server
      extend ActiveSupport::Concern

      included do
        alias_method_chain :security_groups, :no_id
        attr_reader :nics
        attr_writer :security_group, :network # floating IP
      end

      def to_s
        name
      end

      def start
        if state.downcase == 'paused'
          service.unpause_server(id)
        else
          service.resume_server(id)
        end
      end

      def stop
        service.suspend_server(id)
      end

      def pause
        service.pause_server(id)
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

      def network
        return @network if @network # in case we didnt submitting the form again after an error.
        return networks.try(:first).try(:name) if persisted?
        nil
      end

      def security_group
        return @security_group if @security_group # in case we didnt submitting the form again after an error.
        return security_groups.try(:first).try(:name) if persisted?
        nil
      end

      def reset
        reboot('HARD')
      end

      def vm_description
        service.flavors.get(flavor_ref).try(:name)
      end

    end
  end
end
