module Foreman
  class Plugin
    class RbacSupport
      # These plugins can be extended by plugins through plugin API
      AUTO_EXTENDED_ROLES = [Role::VIEWER, Role::MANAGER, Role::ORG_ADMIN, Role::SYSTEM_ADMIN, Role::SITE_MANAGER]

      def add_all_permissions_to_default_roles(all_permissions)
        view_permissions = all_permissions.where("name LIKE :name", :name => "view_%")
        org_admin_permissions = all_permissions.merge(Permission.where.not(resource_type: 'Organization').or(Permission.where(resource_type: nil)))
        Role.transaction do
          add_all_permissions_to_role(Role::MANAGER, all_permissions)
          add_all_permissions_to_role(Role::ORG_ADMIN, org_admin_permissions)
          add_all_permissions_to_role(Role::VIEWER, view_permissions)
        end
      rescue ActiveRecord::StatementInvalid => e
        Foreman::Logging.exception _("Could not add permissions to Manager and Viewer roles: %s") % e.message, e, :level => :debug
      end

      def add_resource_permissions_to_default_roles(resources, opts = {})
        # to get early warnings on typos
        resources.map(&:constantize)
        Role.without_auditing do
          Role.transaction do
            add_resource_permissions_to_viewer(resources, opts.dup)
            add_resource_permissions_to_manager(resources, opts.dup)
            add_resource_permissions_to_organization_admin(resources, opts.dup)
          end
        end
      end

      def add_permissions_to_default_roles(roles)
        roles.each do |role_name, permissions|
          check_role_name_before_extending role_name
          role = Role.find_by :name => role_name
          next unless role
          include_permissions_for_role(role, permissions)
        end
      end

      def check_role_name_before_extending(role_name)
        msg = "Invalid role name, only '#{AUTO_EXTENDED_ROLES.map { |r| "'#{r}'" }.join(', ')}' is allowed to be extended from a plugin"
        raise Foreman::Exception.new msg unless AUTO_EXTENDED_ROLES.include?(role_name)
      end

      def add_resource_permissions_to_manager(resources, opts)
        manager = Role.find_by :name => Role::MANAGER
        return if !manager || resources.empty?
        include_permissions manager, resources, opts
      rescue ActiveRecord::StatementInvalid => e
        Foreman::Logging.exception _("Could not add permissions to Manager role: %s") % e.message, e, :level => :debug
      end

      def add_resource_permissions_to_viewer(resources, opts)
        viewer = Role.find_by :name => Role::VIEWER
        opts[:condition] = "name LIKE :name"
        opts[:condition_hash] = { :name => "view_%" }
        return if !viewer || resources.empty?
        include_permissions viewer, resources, opts
      rescue ActiveRecord::StatementInvalid => e
        Foreman::Logging.exception _("Could not add permissions to Viewer role: %s") % e.message, e, :level => :debug
      end

      def add_resource_permissions_to_organization_admin(resources, opts)
        organization_admin = Role.find_by :name => Role::ORG_ADMIN
        opts[:condition] = "resource_type <> :not_resource_type"
        opts[:condition_hash] = { :not_resource_type => "Organization" }
        return if !organization_admin || resources.empty?
        include_permissions organization_admin, resources, opts
      rescue ActiveRecord::StatementInvalid => e
        Foreman::Logging.exception _("Could not add permissions to Organization admin role: %s") % e.message, e, :level => :debug
      end

      def include_permissions(role, resources, opts)
        to_add = resources.flat_map { |resource| new_permissions_for role, resource, opts }.map(&:name)
        role.ignore_locking do |this_role|
          this_role.add_permissions! to_add if to_add.any?
        end
      end

      def new_permissions_for(role, resource, opts)
        condition_hash = { :resource_type => resource }
        condition_hash.merge! opts[:condition_hash] if opts[:condition_hash]
        conditions = "resource_type = :resource_type"
        conditions << (" AND " + opts[:condition]) if opts[:condition]
        sanitized = ActiveRecord::Base.sanitize_sql_for_conditions([conditions, condition_hash])
        all_permissions = Permission.where(sanitized)
        all_permissions.reject do |permission|
          permission_already_included? role, permission, opts
        end
      end

      def permission_already_included?(role, permission, opts)
        opts[:except] ||= []
        opts[:except].include?(permission.name.to_sym) || role.permissions.where(:name => permission.name).any?
      end

      def include_permissions_for_role(role, permission_names)
        role.ignore_locking do |this_role|
          Role.without_auditing do
            existing_permissions = this_role.permissions.where(:name => permission_names).pluck(:name)
            to_add = permission_names.select { |name| !existing_permissions.include?(name) }
            Role.skip_permission_check do
              this_role.add_permissions! to_add if to_add.any?
            end
          end
        end
      end

      def add_all_permissions_to_role(role_name, permissions)
        role = Role.find_by :name => role_name
        return unless role
        include_permissions_for_role role, permissions.map(&:name)
      rescue ActiveRecord::StatementInvalid => e
        Foreman::Logging.exception _("Could not extend role '%{name}': %{message}") % {:name => role_name, :message => e.message}, e, :level => :debug
      end
    end
  end
end
