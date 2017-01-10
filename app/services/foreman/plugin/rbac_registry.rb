module Foreman
  class Plugin
    class RbacRegistry
      attr_accessor :role_ids, :permission_names, :default_roles

      def initialize
        @role_ids = []
        @permission_names = []
        @default_roles = {}
      end

      def registered_roles
        Role.where(:id => @role_ids)
      end

      def registered_permissions
        Permission.where(:name => @permission_names.map(&:to_s))
      end

      # needed for fixtures permissions.yml,
      # because we do not write plugin permissions and roles to db when registering in test
      def permissions
        registered_permissions.inject({}.with_indifferent_access) do |memo, perm|
          memo.tap { |mem| mem[perm.name] = { :resource_type => perm.resource_type } }
        end
      end
    end
  end
end
