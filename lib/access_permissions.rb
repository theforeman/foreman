require 'foreman/access_control'

# Permissions
Foreman::AccessControl.map do |map|
  map.security_block :architectures do |map|
    map.permission :view_architectures,    {:architectures => [:index, :show]}
    map.permission :create_architectures,  {:architectures => [:new, :create]}
    map.permission :edit_architectures,    {:architectures => [:edit, :update]}
    map.permission :destroy_architectures, {:architectures => [:destroy]}
  end

  map.security_block :authentication_providers do |map|
    map.permission :view_authenticators,    {:auth_source_ldaps => [:index, :show]}
    map.permission :create_authenticators,  {:auth_source_ldaps => [:new, :create]}
    map.permission :edit_authenticators,    {:auth_source_ldaps => [:edit, :update]}
    map.permission :destroy_authenticators, {:auth_source_ldaps => [:destroy]}
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

  map.security_block :domains do |map|
    map.permission :view_domains,       {:domains => [:index, :show]}
    map.permission :create_domain,      {:domains => [:new, :create]}
    map.permission :edit_domains,       {:domains => [:edit, :update]}
    map.permission :destroy_domains,    {:domains => [:destroy]}
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
    map.permission :build_hosts,   {:hosts => [:setBuild, :cancelBuild]}
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

  map.security_block :config_templates do |map|
    map.permission :view_templates,    {:config_templates => [:index, :show]}
    map.permission :create_templates,  {:config_templates => [:new, :create]}
    map.permission :edit_templates,    {:config_templates => [:edit, :update]}
    map.permission :destroy_templates, {:config_templates => [:destroy]}
  end

  map.security_block :operatingsystems do |map|
    map.permission :view_operatingsystems,    {:operatingsystems => [:index, :show]}
    map.permission :create_operatingsystems,  {:operatingsystems => [:new, :create]}
    map.permission :edit_operatingsystems,    {:operatingsystems => [:edit, :update]}
    map.permission :destroy_operatingsystems, {:operatingsystems => [:destroy]}
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

  map.security_block :usergroups do |map|
    map.permission :view_usergroups,    {:usergroups => [:index, :show]}
    map.permission :create_usergroups,  {:usergroups => [:new, :create]}
    map.permission :edit_usergroups,    {:usergroups => [:edit, :update]}
    map.permission :destroy_usergroups, {:usergroups => [:destroy]}
  end

  map.security_block :users do |map|
    map.permission :view_users,    {:users => [:index, :show]}
    map.permission :create_users,  {:users => [:new, :create]}
    map.permission :edit_users,    {:users => [:edit, :update]}
    map.permission :destroy_users, {:users => [:destroy]}
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
