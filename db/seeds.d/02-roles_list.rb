class RolesList
  class << self
    def seeded_roles
      { 'Manager'               => base_manage_permissions + view_permissions + manage_organizations_permissions,
        'Organization admin'    => base_manage_permissions + view_permissions - [:view_organizations],
        'Edit partition tables' => [:view_ptables, :create_ptables, :edit_ptables, :destroy_ptables],
        'View hosts'            => [:view_hosts],
        'Edit hosts'            => [:view_hosts, :edit_hosts, :create_hosts, :destroy_hosts, :build_hosts],
        'Viewer'                => view_permissions,
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
                                    :view_params, :view_ssh_keys]
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
      [:create_architectures, :edit_architectures, :destroy_architectures,
       :create_authenticators, :edit_authenticators, :destroy_authenticators,
       :create_bookmarks, :edit_bookmarks, :destroy_bookmarks,
       :create_compute_resources, :edit_compute_resources, :destroy_compute_resources,
       :create_compute_resources_vms, :edit_compute_resources_vms, :destroy_compute_resources_vms, :power_compute_resources_vms, :console_compute_resources_vms,
       :create_domains, :edit_domains, :destroy_domains,
       :create_realms, :edit_realms, :destroy_realms,
       :create_environments, :edit_environments, :destroy_environments, :import_environments,
       :create_external_variables, :edit_external_variables, :destroy_external_variables,
       :create_external_parameters, :edit_external_parameters, :destroy_external_parameters,
       :create_hostgroups, :edit_hostgroups, :destroy_hostgroups,
       :create_hosts, :edit_hosts, :destroy_hosts, :build_hosts, :power_hosts, :console_hosts, :ipmi_boot_hosts, :puppetrun_hosts,
       :edit_classes,
       :create_params, :edit_params, :destroy_params,
       :create_images, :edit_images, :destroy_images,
       :create_locations, :edit_locations, :destroy_locations, :assign_locations,
       :create_media, :edit_media, :destroy_media,
       :create_models, :edit_models, :destroy_models,
       :create_operatingsystems, :edit_operatingsystems, :destroy_operatingsystems,
       :create_provisioning_templates, :edit_provisioning_templates, :destroy_provisioning_templates, :deploy_provisioning_templates,
       :create_ptables, :edit_ptables, :destroy_ptables,
       :create_puppetclasses, :edit_puppetclasses, :destroy_puppetclasses, :import_puppetclasses,
       :create_smart_proxies, :edit_smart_proxies, :destroy_smart_proxies,
       :create_smart_proxies_autosign, :destroy_smart_proxies_autosign,
       :edit_smart_proxies_puppetca, :destroy_smart_proxies_puppetca,
       :create_ssh_keys, :destroy_ssh_keys,
       :create_subnets, :edit_subnets, :destroy_subnets, :import_subnets,
       :create_usergroups, :edit_usergroups, :destroy_usergroups,
       :create_users, :edit_users, :destroy_users,
       :destroy_config_reports, :upload_config_reports,
       :upload_facts,
       :create_trends, :edit_trends, :destroy_trends, :update_trends]
    end

    def manage_organizations_permissions
      [
        :create_organizations, :edit_organizations, :destroy_organizations, :assign_organizations
      ]
    end

    def view_permissions
      [
        :view_architectures, :view_authenticators, :view_bookmarks, :view_compute_resources, :view_compute_resources_vms, :view_compute_profiles,
        :view_config_groups, :view_domains, :view_realms, :view_environments, :view_external_usergroups, :view_external_variables,
        :view_external_parameters, :view_filters, :view_hostgroups, :view_keypairs,
        :view_hosts, :view_params, :view_images, :view_locations, :view_media, :view_models, :view_operatingsystems,
        :view_provisioning_templates, :view_ptables, :view_puppetclasses, :view_smart_proxies, :view_smart_proxies_autosign,
        :view_smart_proxies_puppetca, :view_subnets, :view_organizations, :view_usergroups, :view_users, :view_config_reports,
        :view_facts, :view_audit_logs, :view_statistics, :view_tasks, :view_trends, :view_plugins, :view_mail_notifications,
        :access_dashboard, :view_roles, :view_ssh_keys
      ]
    end
  end
end
