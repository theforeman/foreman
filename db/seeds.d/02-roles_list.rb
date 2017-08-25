require (Rails.root + 'db/seeds.d/02-permissions_list.rb')

class RolesList
  class << self
    def seeded_roles
      { Role::MANAGER           => base_manage_permissions + view_permissions + manage_organizations_permissions,
        Role::ORG_ADMIN         => base_manage_permissions + view_permissions - [:view_organizations],
        'Edit partition tables' => [:view_ptables, :create_ptables, :edit_ptables, :destroy_ptables],
        'View hosts'            => [:view_hosts],
        'Edit hosts'            => [:view_hosts, :edit_hosts, :create_hosts, :destroy_hosts, :build_hosts],
        Role::VIEWER            => view_permissions,
        'Site manager'          => [:view_architectures, :view_audit_logs, :view_authenticators, :access_dashboard,
                                    :view_domains, :view_environments, :import_environments, :view_external_variables,
                                    :create_external_variables, :edit_external_variables, :destroy_external_variables,
                                    :view_external_parameters, :create_external_parameters, :edit_external_parameters,
                                    :destroy_external_parameters, :view_facts, :view_hostgroups, :view_hosts, :view_smart_proxies_puppetca,
                                    :view_smart_proxies_autosign, :create_hosts, :edit_hosts, :destroy_hosts,
                                    :build_hosts, :view_media, :create_media, :edit_media, :destroy_media,
                                    :view_models, :view_operatingsystems, :view_ptables, :view_puppetclasses,
                                    :import_puppetclasses, :view_config_reports, :destroy_config_reports,
                                    :view_smart_proxies, :edit_smart_proxies, :view_subnets, :edit_subnets,
                                    :view_statistics, :view_usergroups, :create_usergroups, :edit_usergroups,
                                    :destroy_usergroups, :view_users, :edit_users, :view_realms, :view_mail_notifications,
                                    :view_params, :view_ssh_keys],
      'Bookmarks manager'       => [:view_bookmarks, :create_bookmarks, :edit_bookmarks, :destroy_bookmarks]
      }
    end

    def default_role
      {
        'Default role' => [:view_bookmarks, :view_tasks]
      }
    end

    def roles
      seeded_roles.merge default_role
    end

    def role_names
      roles.map { |name, permissions| name }
    end

    def base_manage_permissions
      PermissionsList.permissions.reject { |resource, name| name.start_with?('view_') }.map { |p| p.last.to_sym } - manage_organizations_permissions
    end

    def manage_organizations_permissions
      [
        :create_organizations, :edit_organizations, :destroy_organizations, :assign_organizations
      ]
    end

    def view_permissions
      PermissionsList.permissions.select { |resource, name| name.start_with?('view_') }.map { |p| p.last.to_sym }
    end

    def roles_descriptions
      {
        Role::MANAGER => 'Role granting all available permissions. With this role, user is able to do everything that admin can except for changing Settings.',
        Role::ORG_ADMIN => 'Role granting all permissions except for managing organizations. It can be used to delegate administration of specific organization to a user. In order to create such role, clone this role and assign desired organizations',
        'Edit partition tables' => 'Role granting permissions required for managin partition tables',
        'View hosts' => 'Role granting permission only to view hosts',
        'Edit hosts' => 'Role granting permissions to update hosts. For features provided by plugins, you might need to combine this role with roles provided by those plugins',
        Role::VIEWER => 'Role granting read only access. Users with this role can see all data but can not do any modifications',
        'Site manager' => 'Role granting mostly view permissions but also permissions required for managing hosts in the infrastructure. Users with this role can update puppet parameters, create and edit hosts, manage installation media, subnets, usergroups and edit existing users.',
        'Bookmarks user' => 'Role granting permissions for managing search bookmarks. Usually useful in combination with Viewer role. This role also grants the permission to update all public bookmarks.',
        'Default role' => 'Role that is automatically assigned to every user in the system. Adding a permission grants it to everybody'
      }
    end
  end
end
