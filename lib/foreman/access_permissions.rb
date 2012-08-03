require 'foreman/access_control'

# Permissions
Foreman::AccessControl.map do |map|
  map.security_block :architectures do |map|
    map.permission :view_architectures,
                   :architectures => [:index, :show], :"api/v1/architectures" => [:index, :show]
    map.permission :create_architectures,
                   :architectures => [:new, :create], :"api/v1/architectures" => [:new, :create]
    map.permission :edit_architectures,
                   :architectures => [:edit, :update], :"api/v1/architectures" => [:edit, :update]
    map.permission :destroy_architectures,
                   :architectures => [:destroy], :"api/v1/architectures" => [:destroy]
  end

  map.security_block :authentication_providers do |map|
    map.permission :view_authenticators,    {:auth_source_ldaps => [:index, :show]}
    map.permission :create_authenticators,  {:auth_source_ldaps => [:new, :create]}
    map.permission :edit_authenticators,    {:auth_source_ldaps => [:edit, :update]}
    map.permission :destroy_authenticators, {:auth_source_ldaps => [:destroy]}
  end

  map.security_block :bookmarks do |map|
    map.permission :view_bookmarks,
                   :bookmarks => [:index, :show], :"api/v1/bookmarks" => [:index, :show]
    map.permission :create_bookmarks,
                   :bookmarks => [:new, :create], :"api/v1/bookmarks" => [:new, :create]
    map.permission :edit_bookmarks,
                   :bookmarks => [:edit, :update], :"api/v1/bookmarks" => [:edit, :update]
    map.permission :destroy_bookmarks,
                   :bookmarks => [:destroy], :"api/v1/bookmarks" => [:destroy]
  end

  map.security_block :compute_resources do |map|
    map.permission :view_compute_resources,    {:compute_resources => [:index, :show]}
    map.permission :create_compute_resources,  {:compute_resources => [:new, :create]}
    map.permission :edit_compute_resources,    {:compute_resources => [:edit, :update]}
    map.permission :destroy_compute_resources, {:compute_resources => [:destroy]}
  end

  map.security_block :compute_resources_vms do |map|
    map.permission :view_compute_resources_vms,    {:compute_resources_vms => [:index, :show]}
    map.permission :create_compute_resources_vms,  {:compute_resources_vms => [:create]}
    map.permission :destroy_compute_resources_vms, {:compute_resources_vms => [:destroy]}
    map.permission :power_compute_resources_vms,   {:compute_resources_vms => [:power]}
  end

  map.security_block :config_templates do |map|
    map.permission :view_templates,    {:config_templates => [:index, :show]}
    map.permission :create_templates,  {:config_templates => [:new, :create]}
    map.permission :edit_templates,    {:config_templates => [:edit, :update]}
    map.permission :destroy_templates, {:config_templates => [:destroy]}
  end

  map.security_block :domains do |map|
    map.permission :view_domains,       {:domains => [:index, :show]}
    map.permission :create_domain,      {:domains => [:new, :create]}
    map.permission :edit_domains,       {:domains => [:edit, :update]}
    map.permission :destroy_domains,    {:domains => [:destroy]}
  end

  map.security_block :environments do |map|
    map.permission :view_environments,    {:environments => [:index, :show]}
    map.permission :create_environments,  {:environments => [:new, :create]}
    map.permission :edit_environments,    {:environments => [:edit, :update]}
    map.permission :destroy_environments, {:environments => [:destroy]}
    map.permission :import_environments,  {:environments => [:import_environments, :obsolete_and_new]}
  end

  map.security_block :external_variables do |map|
    map.permission :view_external_variables,    {:lookup_keys => [:index, :show]}
    map.permission :create_external_variables,  {:lookup_keys => [:new, :create]}
    map.permission :edit_external_variables,    {:lookup_keys => [:edit, :update]}
    map.permission :destroy_external_variables, {:lookup_keys => [:destroy]}
  end

  map.security_block :global_variables do |map|
    map.permission :view_globals,    {:common_parameters => [:index, :show]}
    map.permission :create_globals,  {:common_parameters => [:new, :create]}
    map.permission :edit_globals,    {:common_parameters => [:edit, :update]}
    map.permission :destroy_globals, {:common_parameters => [:destroy]}
  end

  map.security_block :hostgroups do |map|
    map.permission :view_hostgroups,       {:hostgroups => [:index, :show]}
    map.permission :create_hostgroups,     {:hostgroups => [:new, :create, :clone]}
    map.permission :edit_hostgroups,       {:hostgroups => [:edit, :update]}
    map.permission :destroy_hostgroups,    {:hostgroups => [:destroy]}
  end

  map.security_block :hosts do |map|
    map.permission :view_hosts,    {:hosts => [:index, :show, :errors, :active, :out_of_sync, :disabled], :dashboard => [:OutOfSync, :errors, :active]}
    map.permission :create_hosts,  {:hosts => [:new, :create, :clone]}
    map.permission :edit_hosts,    {:hosts => [:edit, :update, :multiple_actions, :reset_multiple,
                                      :select_multiple_hostgroup, :select_multiple_environment, :submit_multiple_disable,
                                      :multiple_parameters, :multiple_disable, :multiple_enable, :update_multiple_environment,
                                      :update_multiple_hostgroup, :update_multiple_parameters, :toggle_manage]}
    map.permission :destroy_hosts, {:hosts => [:destroy, :multiple_actions, :reset_multiple, :multiple_destroy, :submit_multiple_destroy]}
    map.permission :build_hosts,   {:hosts => [:setBuild, :cancelBuild, :submit_multiple_build]}
    map.permission :power_hosts,   {:hosts => [:power]}
    map.permission :console_hosts, {:hosts => [:console]}
  end

  map.security_block :host_editing do |map|
    map.permission :edit_classes,   {:host_editing => [:edit_classes]}
    map.permission :create_params,  {:host_editing => [:create_params]}
    map.permission :edit_params,    {:host_editing => [:edit_params]}
    map.permission :destroy_params, {:host_editing => [:destroy_params]}
  end

  map.security_block :hypervisors do |map|
    map.permission :view_hypervisors,    {:hypervisors => [:index, :show]}
    map.permission :create_hypervisors,  {:hypervisors => [:new, :create]}
    map.permission :edit_hypervisors,    {:hypervisors => [:edit, :update]}
    map.permission :destroy_hypervisors, {:hypervisors => [:destroy]}
  end

  map.security_block :hypervisors_guests do |map|
    map.permission :view_hypervisors_guests,    {:hypervisors_guests => [:index, :show]}
    map.permission :create_hypervisors_guests,  {:hypervisors_guests => [:create, :update]}
    map.permission :destroy_hypervisors_guests, {:hypervisors_guests => [:destroy]}
    map.permission :power_hypervisors_guests,   {:hypervisors_guests => [:power]}
  end

  map.security_block :media do |map|
    map.permission :view_media,    {:media => [:index, :show]}
    map.permission :create_media,  {:media => [:new, :create]}
    map.permission :edit_media,    {:media => [:edit, :update]}
    map.permission :destroy_media, {:media => [:destroy]}
  end

  map.security_block :models do |map|
    map.permission :view_models,    {:models => [:index, :show]}
    map.permission :create_models,  {:models => [:new, :create]}
    map.permission :edit_models,    {:models => [:edit, :update]}
    map.permission :destroy_models, {:models => [:destroy]}
  end

  map.security_block :operatingsystems do |map|
    map.permission :view_operatingsystems,
                   :operatingsystems => [:index, :show], :"api/v1/operatingsystems" => [:index, :show]
    map.permission :create_operatingsystems,
                   :operatingsystems => [:new, :create], :"api/v1/operatingsystems" => [:new, :create]
    map.permission :edit_operatingsystems,
                   :operatingsystems => [:edit, :update], :"api/v1/operatingsystems" => [:edit, :update]
    map.permission :destroy_operatingsystems,
                   :operatingsystems => [:destroy], :"api/v1/operatingsystems" => [:destroy]
  end

  map.security_block :partition_tables do |map|
    map.permission :view_ptables,    {:ptables => [:index, :show]}
    map.permission :create_ptables,  {:ptables => [:new, :create]}
    map.permission :edit_ptables,    {:ptables => [:edit, :update]}
    map.permission :destroy_ptables, {:ptables => [:destroy]}
  end

  map.security_block :puppetclasses do |map|
    map.permission :view_puppetclasses,    {:puppetclasses => [:index, :show]}
    map.permission :create_puppetclasses,  {:puppetclasses => [:new, :create]}
    map.permission :edit_puppetclasses,    {:puppetclasses => [:edit, :update]}
    map.permission :destroy_puppetclasses, {:puppetclasses => [:destroy]}
    map.permission :import_puppetclasses,  {:puppetclasses => [:import_environments]}
  end

  map.security_block :smart_proxies do |map|
    map.permission :view_smart_proxies,    {:smart_proxies => [:index, :show]}
    map.permission :create_smart_proxies,  {:smart_proxies => [:new, :create]}
    map.permission :edit_smart_proxies,    {:smart_proxies => [:edit, :update]}
    map.permission :destroy_smart_proxies, {:smart_proxies => [:destroy]}
  end

  map.security_block :smart_proxies_autosign do |map|
    map.permission :view_smart_proxies_autosign,    {:smart_proxies_autosign => [:index, :show]}
    map.permission :create_smart_proxies_autosign,  {:smart_proxies_autosign => [:new, :create]}
    map.permission :destroy_smart_proxies_autosign, {:smart_proxies_autosign => [:destroy]}
  end

  map.security_block :smart_proxies_puppetca do |map|
    map.permission :view_smart_proxies_puppetca,    {:smart_proxies_puppetca => [:index]}
    map.permission :edit_smart_proxies_puppetca,    {:smart_proxies_puppetca => [:update]}
    map.permission :destroy_smart_proxies_puppetca, {:smart_proxies_puppetca => [:destroy]}
  end

  map.security_block :subnets do |map|
    map.permission :view_subnets,    {:subnets => [:index, :show]}
    map.permission :create_subnets,  {:subnets => [:new, :create]}
    map.permission :edit_subnets,    {:subnets => [:edit, :update]}
    map.permission :destroy_subnets, {:subnets => [:destroy]}
  end

  map.security_block :usergroups do |map|
    map.permission :view_usergroups,    {:usergroups => [:index, :show]}
    map.permission :create_usergroups,  {:usergroups => [:new, :create]}
    map.permission :edit_usergroups,    {:usergroups => [:edit, :update]}
    map.permission :destroy_usergroups, {:usergroups => [:destroy]}
  end

  map.security_block :users do |map|
    map.permission :view_users,
                   :users => [:index, :show], :"api/v1/users" => [:index, :show]
    map.permission :create_users,
                   :users => [:new, :create], :"api/v1/users" => [:new, :create]
    map.permission :edit_users,
                   :users => [:edit, :update], :"api/v1/users" => [:edit, :update]
    map.permission :destroy_users,
                   :users => [:destroy], :"api/v1/users" => [:destroy]
  end

  map.security_block :settings_menu do |map|
    map.permission :access_settings,  {:home => [:settings]}
  end

  map.security_block :dashboard do |map|
    map.permission :access_dashboard, {:dashboard => [:index]}
  end

  map.security_block :reports do |map|
    map.permission :view_reports,    {:reports     => [:index, :show]}
    map.permission :destroy_reports, {:reports     => [:destroy]}
  end

  map.security_block :facts do |map|
    map.permission :view_facts,       {:fact_values => [:index, :show]}
  end

  map.security_block :audit_logs do |map|
    map.permission :view_audit_logs,  {:audits      => [:index, :show]}
  end
  map.security_block :statistics do |map|
    map.permission :view_statistics,  {:statistics  => [:index, :show]}
  end

end
