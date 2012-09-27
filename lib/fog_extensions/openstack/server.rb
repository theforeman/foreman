module FogExtensions
  module Openstack
    module Server

      #TODO: get as much of this merged into fog 1.5

      def tenant
        connection.tenants.detect{|t| t.id == tenant_id }
      end

      def start
        connection.resume_server(id)
      end

      def stop
        connection.suspend_server(id)
      end

      def flavor_with_object
        connection.flavors.get attributes[:flavor]['id']
      end

      def first_private_ip_address
        private_ip_address["addr"]
      end

      def created_at
        Time.parse attributes['created']
      end

      def security_groups
        connection.security_groups.all
      end

    end
  end
end
