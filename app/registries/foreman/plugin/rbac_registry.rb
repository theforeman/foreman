module Foreman
  class Plugin
    class RbacRegistry
      attr_accessor :role_ids, :default_roles, :registered_permissions

      def initialize
        @role_ids = []
        @registered_permissions = []
        @default_roles = {}
      end

      def registered_roles
        Role.where(:id => @role_ids)
      end

      def register(name, options)
        @registered_permissions << [name, options]
      end

      # needed for fixtures permissions.yml,
      # because we do not write plugin permissions and roles to db when registering in test
      def permissions
        Hash[registered_permissions.map { |name, options| [name, :resource_type => options[:resource_type]] }].with_indifferent_access
      end

      def permission_names
        registered_permissions.map(&:first)
      end
    end
  end
end
