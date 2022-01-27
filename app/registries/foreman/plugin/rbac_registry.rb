module Foreman
  class Plugin
    class RbacRegistry
      attr_accessor :role_ids, :default_roles, :registered_permissions
      attr_accessor :add_all_permissions_to_default_roles, :default_roles_permissions_blocklist
      attr_reader :modified_roles
      attr_reader :added_resource_permissions

      def initialize(plugin_id)
        @plugin_id = plugin_id
        @role_ids = []
        @registered_permissions = []
        @default_roles = {}
        @default_role_descriptions = {}
        @modified_roles = {}
        @default_roles_permissions_blocklist = []
        @added_resource_permissions = []
        @add_all_permissions_to_default_roles = false
      end

      def registered_roles
        Role.where(:id => @role_ids)
      end

      def register(name, options)
        @registered_permissions << [name, options]
      end

      def register_role(name, permissions, description = '')
        default_roles[name] = permissions
        @default_role_descriptions[name] = description
      end

      # needed for fixtures permissions.yml,
      # because we do not write plugin permissions and roles to db when registering in test
      def permissions
        Hash[registered_permissions.map { |name, options| [name, :resource_type => options[:resource_type]] }].with_indifferent_access
      end

      def permission_names
        registered_permissions.map(&:first)
      end

      def setup!
        setup_permissions!
        setup_roles!
      end

      def setup_permissions!
        return false if Foreman.in_setup_db_rake? || !permission_table_exists?
        registered_permissions.each do |(name, options)|
          Permission.where(:name => name).first_or_create(:resource_type => options[:resource_type])
        end
      end

      def setup_roles!
        return false if Foreman.in_setup_db_rake? || !permission_table_exists? || User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).nil?
        Role.without_auditing do
          Filter.without_auditing do
            default_roles.each do |name, permissions|
              Plugin::RoleLock.new(@plugin_id).register_role name, permissions, self, @default_role_descriptions[name] || ''
            rescue PermissionMissingException => e
              Rails.logger.warn(_("Could not create role '%{name}': %{message}") % {:name => name, :message => e.message})
              return false if Foreman.in_rake?
              Rails.logger.error(_('Cannot continue because some permissions were not found, please run rake db:seed and retry'))
              raise e
            end

            next unless permission_table_exists?
            rbac_support = Plugin::RbacSupport.new
            if add_all_permissions_to_default_roles
              filtered_permission_names = permission_names.reject { |p| @default_roles_permissions_blocklist.include? p }
              rbac_support.add_all_permissions_to_default_roles(Permission.where(name: filtered_permission_names))
            end
            rbac_support.add_permissions_to_default_roles(modified_roles) if modified_roles.any?
            added_resource_permissions.each do |(resources, opts)|
              rbac_support.add_resource_permissions_to_default_roles resources, opts
            end
          end
        end
      end

      private

      def permission_table_exists?
        exists = Permission.connection.table_exists?(Permission.table_name)
        Rails.logger.debug("Not adding permissions from plugin #{@id} to default roles - permissions table not found") if !exists && !Rails.env.test?
        exists
      end
    end
  end
end
