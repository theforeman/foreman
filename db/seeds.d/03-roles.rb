# Roles
def view_permissions
  Permission.all.map(&:name).select { |permission_name| permission_name.match /view/ }.map(&:to_sym)
end

default_permissions =
    { 'Manager'               => [:view_architectures, :create_architectures, :edit_architectures, :destroy_architectures,
                                  :view_authenticators, :create_authenticators, :edit_authenticators, :destroy_authenticators,
                                  :view_bookmarks, :create_bookmarks, :edit_bookmarks, :destroy_bookmarks,
                                  :view_compute_resources, :create_compute_resources, :edit_compute_resources, :destroy_compute_resources,
                                  :view_compute_resources_vms, :create_compute_resources_vms, :edit_compute_resources_vms, :destroy_compute_resources_vms, :power_compute_resources_vms, :console_compute_resources_vms,
                                  :view_templates, :create_templates, :edit_templates, :destroy_templates, :deploy_templates,
                                  :view_domains, :create_domains, :edit_domains, :destroy_domains,
                                  :view_realms, :create_realms, :edit_realms, :destroy_realms,
                                  :view_environments, :create_environments, :edit_environments, :destroy_environments, :import_environments,
                                  :view_external_variables, :create_external_variables, :edit_external_variables, :destroy_external_variables,
                                  :view_globals, :create_globals, :edit_globals, :destroy_globals,
                                  :view_hostgroups, :create_hostgroups, :edit_hostgroups, :destroy_hostgroups,
                                  :view_hosts, :create_hosts, :edit_hosts, :destroy_hosts, :build_hosts, :power_hosts, :console_hosts, :ipmi_boot, :puppetrun_hosts,
                                  :edit_classes, :create_params, :edit_params, :destroy_params,
                                  :view_images, :create_images, :edit_images, :destroy_images,
                                  :view_locations, :create_locations, :edit_locations, :destroy_locations, :assign_locations,
                                  :view_media, :create_media, :edit_media, :destroy_media,
                                  :view_models, :create_models, :edit_models, :destroy_models,
                                  :view_operatingsystems, :create_operatingsystems, :edit_operatingsystems, :destroy_operatingsystems,
                                  :view_ptables, :create_ptables, :edit_ptables, :destroy_ptables,
                                  :view_puppetclasses, :create_puppetclasses, :edit_puppetclasses, :destroy_puppetclasses, :import_puppetclasses,
                                  :view_smart_proxies, :create_smart_proxies, :edit_smart_proxies, :destroy_smart_proxies,
                                  :view_smart_proxies_autosign, :create_smart_proxies_autosign, :destroy_smart_proxies_autosign,
                                  :view_smart_proxies_puppetca, :edit_smart_proxies_puppetca, :destroy_smart_proxies_puppetca,
                                  :view_subnets, :create_subnets, :edit_subnets, :destroy_subnets, :import_subnets,
                                  :view_organizations, :create_organizations, :edit_organizations, :destroy_organizations, :assign_organizations,
                                  :view_usergroups, :create_usergroups, :edit_usergroups, :destroy_usergroups,
                                  :view_users, :create_users, :edit_users, :destroy_users, :access_settings, :access_dashboard,
                                  :view_config_reports, :destroy_config_reports, :upload_config_reports,
                                  :view_facts, :upload_facts, :view_audit_logs,
                                  :view_statistics, :view_trends, :create_trends, :edit_trends, :destroy_trends, :update_trends,
                                  :view_tasks, :view_plugins, :view_mail_notifications],
      'Edit partition tables' => [:view_ptables, :create_ptables, :edit_ptables, :destroy_ptables],
      'View hosts'            => [:view_hosts],
      'Edit hosts'            => [:view_hosts, :edit_hosts, :create_hosts, :destroy_hosts, :build_hosts],
      'Viewer'                => (view_permissions << [:access_settings, :access_dashboard]).flatten,
      'Site manager'          => [:view_architectures, :view_audit_logs, :view_authenticators, :access_dashboard,
                                  :view_domains, :view_environments, :import_environments, :view_external_variables,
                                  :create_external_variables, :edit_external_variables, :destroy_external_variables,
                                  :view_facts, :view_globals, :view_hostgroups, :view_hosts, :view_smart_proxies_puppetca,
                                  :view_smart_proxies_autosign, :create_hosts, :edit_hosts, :destroy_hosts,
                                  :build_hosts, :view_media, :create_media, :edit_media, :destroy_media,
                                  :view_models, :view_operatingsystems, :view_ptables, :view_puppetclasses,
                                  :import_puppetclasses, :view_config_reports, :destroy_config_reports, :access_settings,
                                  :view_smart_proxies, :edit_smart_proxies, :view_subnets, :edit_subnets,
                                  :view_statistics, :view_usergroups, :create_usergroups, :edit_usergroups,
                                  :destroy_usergroups, :view_users, :edit_users, :view_realms, :view_mail_notifications],
    }

default_user_permissions = [:view_hosts, :view_puppetclasses, :view_hostgroups, :view_domains,
                            :view_operatingsystems, :view_media, :view_models, :view_environments,
                            :view_architectures, :view_ptables, :view_globals, :view_external_variables,
                            :view_authenticators, :access_settings, :access_dashboard,
                            :view_config_reports, :view_subnets, :view_facts, :view_locations,
                            :view_organizations, :view_statistics, :view_realms, :view_mail_notifications]
anonymous_permissions    = [:view_bookmarks, :view_tasks]

Role.without_auditing do
  default_permissions.each do |role_name, permission_names|
    create_role(role_name, permission_names, 0)
  end
  create_role('Default user', default_user_permissions, Role::BUILTIN_DEFAULT_USER)
  create_role('Anonymous', anonymous_permissions, Role::BUILTIN_ANONYMOUS)
end
