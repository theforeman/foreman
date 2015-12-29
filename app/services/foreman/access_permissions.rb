require 'foreman/access_control'

# Permissions
Foreman::AccessControl.map do |permission_set|
  permission_set.security_block :public do |map|
    map.permission :user_logout, { :users => [:logout] }, :public => true
    map.permission :my_account, { :users => [:edit] }, :public => true
    map.permission :api_status, { :"api/v1/home" => [:status], :"api/v2/home" => [:status]}, :public => true
  end

  permission_set.security_block :architectures do |map|
    map.permission :view_architectures,
                   :architectures => [:index, :show, :auto_complete_search],
                   :"api/v1/architectures" => [:index, :show],
                   :"api/v2/architectures" => [:index, :show]
    map.permission :create_architectures,
                   :architectures => [:new, :create],
                   :"api/v1/architectures" => [:create],
                   :"api/v2/architectures" => [:create]
    map.permission :edit_architectures,
                   :architectures => [:edit, :update],
                   :"api/v1/architectures" => [:update],
                   :"api/v2/architectures" => [:update]
    map.permission :destroy_architectures,
                   :architectures => [:destroy],
                   :"api/v1/architectures" => [:destroy],
                   :"api/v2/architectures" => [:destroy]
  end

  permission_set.security_block :authentication_providers do |map|
    ajax_actions = [:test_connection]
    map.permission :view_authenticators,    {:auth_source_ldaps => [:index, :show],
                                             :"api/v1/auth_source_ldaps" => [:index, :show],
                                             :"api/v2/auth_source_ldaps" => [:index, :show]
    }
    map.permission :create_authenticators,  {:auth_source_ldaps => [:new, :create].push(*ajax_actions),
                                             :"api/v1/auth_source_ldaps" => [:create],
                                             :"api/v2/auth_source_ldaps" => [:create]
    }
    map.permission :edit_authenticators,    {:auth_source_ldaps => [:edit, :update].push(*ajax_actions),
                                             :"api/v1/auth_source_ldaps" => [:update],
                                             :"api/v2/auth_source_ldaps" => [:update, :test]
    }
    map.permission :destroy_authenticators, {:auth_source_ldaps => [:destroy],
                                             :"api/v1/auth_source_ldaps" => [:destroy],
                                             :"api/v2/auth_source_ldaps" => [:destroy]
    }
  end

  permission_set.security_block :bookmarks do |map|
    map.permission :view_bookmarks,
                   :bookmarks => [:index, :show],
                   :"api/v1/bookmarks" => [:index, :show],
                   :"api/v2/bookmarks" => [:index, :show]
    map.permission :create_bookmarks,
                   :bookmarks => [:new, :create],
                   :"api/v1/bookmarks" => [:new, :create],
                   :"api/v2/bookmarks" => [:new, :create]
    map.permission :edit_bookmarks,
                   :bookmarks => [:edit, :update],
                   :"api/v1/bookmarks" => [:edit, :update],
                   :"api/v2/bookmarks" => [:edit, :update]
    map.permission :destroy_bookmarks,
                   :bookmarks => [:destroy],
                   :"api/v1/bookmarks" => [:destroy],
                   :"api/v2/bookmarks" => [:destroy]
  end

  permission_set.security_block :compute_profiles do |map|
    map.permission :view_compute_profiles, { :compute_profiles          => [:index, :show, :auto_complete_search],
                                             :"api/v2/compute_profiles" => [:index, :show] }
    map.permission :create_compute_profiles, { :compute_profiles        => [:new, :create],
                                             :"api/v2/compute_profiles" => [:create] }
    map.permission :edit_compute_profiles, { :compute_profiles          => [:edit, :update],
                                             :"api/v2/compute_profiles" => [:update] }
    map.permission :destroy_compute_profiles, { :compute_profiles          => [:destroy],
                                                :"api/v2/compute_profiles" => [:destroy] }
  end

  permission_set.security_block :compute_resources do |map|
    ajax_actions = [:test_connection]
    map.permission :view_compute_resources,    {:compute_resources => [:index, :show, :auto_complete_search, :ping, :available_images],
                                                :"api/v1/compute_resources" => [:index, :show],
                                                :"api/v2/compute_resources" => [:index, :show, :available_images, :available_clusters, :available_folders,
                                                                                :available_flavors, :available_networks, :available_resource_pools,
                                                                                :available_security_groups, :available_storage_domains, :available_zones]
    }
    map.permission :create_compute_resources,  {:compute_resources => [:new, :create].push(*ajax_actions),
                                                :"api/v1/compute_resources" => [:create],
                                                :"api/v2/compute_resources" => [:create]
    }
    map.permission :edit_compute_resources,    {:compute_resources => [:edit, :update].push(*ajax_actions),
                                                :compute_attributes => [:new, :create, :edit, :update],
                                                :"api/v1/compute_resources" => [:update],
                                                :"api/v2/compute_resources" => [:update],
                                                :"api/v2/compute_attributes" => [:create, :update]
    }
    map.permission :destroy_compute_resources, {:compute_resources => [:destroy],
                                                :"api/v1/compute_resources" => [:destroy],
                                                :"api/v2/compute_resources" => [:destroy]
    }
  end

  permission_set.security_block :compute_resources_vms do |map|
    map.permission :view_compute_resources_vms,    {:compute_resources_vms => [:index, :show]}
    map.permission :create_compute_resources_vms,  {:compute_resources_vms => [:new, :create]}
    map.permission :edit_compute_resources_vms,    {:compute_resources_vms => [:edit, :update]}
    map.permission :destroy_compute_resources_vms, {:compute_resources_vms => [:destroy]}
    map.permission :power_compute_resources_vms,   {:compute_resources_vms => [:power, :pause]}
    map.permission :console_compute_resources_vms, {:compute_resources_vms => [:console]}
  end

  permission_set.security_block :provisioning_templates do |map|
    map.permission :view_provisioning_templates,    {:provisioning_templates => [:index, :show, :revision, :auto_complete_search, :preview],
                                        :"api/v1/config_templates" => [:index, :show, :revision],
                                        :"api/v2/config_templates" => [:index, :show, :revision],
                                        :"api/v2/provisioning_templates" => [:index, :show, :revision],
                                        :"api/v2/template_combinations" => [:index, :show],
                                        :"api/v1/template_kinds" => [:index],
                                        :"api/v2/template_kinds" => [:index]
                                      }
    map.permission :create_provisioning_templates,  {:provisioning_templates => [:new, :create, :clone_template],
                                        :"api/v1/config_templates" => [:create],
                                        :"api/v2/config_templates" => [:create, :clone],
                                        :"api/v2/provisioning_templates" => [:create, :clone],
                                        :"api/v2/template_combinations" => [:create]
                                      }
    map.permission :edit_provisioning_templates,    {:provisioning_templates => [:edit, :update],
                                        :"api/v1/config_templates" => [:update],
                                        :"api/v2/config_templates" => [:update],
                                        :"api/v2/provisioning_templates" => [:update],
                                        :"api/v2/template_combinations" => [:update]
                                      }
    map.permission :destroy_provisioning_templates, {:provisioning_templates => [:destroy],
                                        :"api/v1/config_templates" => [:destroy],
                                        :"api/v2/config_templates" => [:destroy],
                                        :"api/v2/provisioning_templates" => [:destroy],
                                        :"api/v2/template_combinations" => [:destroy]
                                      }
    map.permission :deploy_provisioning_templates,  {:provisioning_templates => [:build_pxe_default],
                                        :"api/v1/config_templates" => [:build_pxe_default],
                                        :"api/v2/config_templates" => [:build_pxe_default],
                                        :"api/v2/provisioning_templates" => [:build_pxe_default]
                                      }

    map.permission :lock_provisioning_templates,    {:provisioning_templates => [:lock, :unlock],
                                        :"api/v2/config_templates" => [:lock, :unlock],
                                        :"api/v2/provisioning_templates" => [:lock, :unlock]
                                      }
  end

  permission_set.security_block :realms do |map|
    map.permission :view_realms,       {:realms => [:index, :show, :auto_complete_search],
                                      :"api/v2/realms" => [:index, :show]
    }
    map.permission :create_realms,      {:realms => [:new, :create],
                                      :"api/v2/realms" => [:create]
    }
    map.permission :edit_realms,       {:realms => [:edit, :update],
                                      :"api/v2/realms" => [:update]
    }
    map.permission :destroy_realms,    {:realms => [:destroy],
                                      :"api/v2/realms" => [:destroy]
    }
  end

  permission_set.security_block :domains do |map|
    map.permission :view_domains,       {:domains => [:index, :show, :auto_complete_search],
                                      :"api/v1/domains" => [:index, :show],
                                      :"api/v2/domains" => [:index, :show],
                                      :"api/v2/parameters" => [:index, :show]
    }
    map.permission :create_domains,      {:domains => [:new, :create],
                                      :"api/v1/domains" => [:create],
                                      :"api/v2/domains" => [:create]
    }
    map.permission :edit_domains,       {:domains => [:edit, :update],
                                      :"api/v1/domains" => [:update],
                                      :"api/v2/domains" => [:update],
                                      :"api/v2/parameters" => [:create, :update, :destroy, :reset]
    }
    map.permission :destroy_domains,    {:domains => [:destroy],
                                      :"api/v1/domains" => [:destroy],
                                      :"api/v2/domains" => [:destroy]
    }
  end

  permission_set.security_block :environments do |map|
    map.permission :view_environments,    {:environments => [:index, :show, :auto_complete_search],
                                           :"api/v1/environments" => [:index, :show],
                                           :"api/v2/environments" => [:index, :show]
    }
    map.permission :create_environments,  {:environments => [:new, :create],
                                           :"api/v1/environments" => [:create],
                                           :"api/v2/environments" => [:create]
    }
    map.permission :edit_environments,    {:environments => [:edit, :update],
                                           :"api/v1/environments" => [:update],
                                           :"api/v2/environments" => [:update]
    }
    map.permission :destroy_environments, {:environments => [:destroy],
                                           :"api/v1/environments" => [:destroy],
                                           :"api/v2/environments" => [:destroy]
    }
    map.permission :import_environments,  {:environments => [:import_environments, :obsolete_and_new],
                                           :"api/v1/environments" => [:import_puppetclasses],
                                           :"api/v2/environments" => [:import_puppetclasses],
                                           :"api/v1/smart_proxies" => [:import_puppetclasses],
                                           :"api/v2/smart_proxies" => [:import_puppetclasses]
                                            }
  end

  permission_set.security_block :external_variables do |map|
    map.permission :view_external_variables,    {:lookup_keys => [:index, :show, :auto_complete_search],
                                                 :puppetclass_lookup_keys => [:index, :show, :auto_complete_search],
                                                 :variable_lookup_keys => [:index, :show, :auto_complete_search],
                                                 :lookup_values => [:index],
                                                 :"api/v1/lookup_keys" => [:index, :show],
                                                 :"api/v2/smart_variables" => [:index, :show],
                                                 :"api/v2/smart_class_parameters" => [:index, :show],
                                                 :"api/v2/override_values" => [:index, :show]}
    map.permission :create_external_variables,  {:lookup_keys => [:new, :create],
                                                 :puppetclass_lookup_keys => [:new, :create],
                                                 :variable_lookup_keys => [:new, :create],
                                                 :lookup_values => [:create],
                                                 :"api/v1/lookup_keys" => [:create],
                                                 :"api/v2/smart_variables" => [:create],
                                                 :"api/v2/smart_class_parameters" => [:create],
                                                 :"api/v2/override_values" => [:create]}
    map.permission :edit_external_variables,    {:lookup_keys => [:edit, :update],
                                                 :puppetclass_lookup_keys => [:edit, :update],
                                                 :variable_lookup_keys => [:edit, :update],
                                                 :lookup_values => [:create, :update, :destroy],
                                                 :"api/v1/lookup_keys" => [:update],
                                                 :"api/v2/smart_variables" => [:update],
                                                 :"api/v2/smart_class_parameters" => [:update],
                                                 :"api/v2/override_values" => [:create, :update, :destroy]}
    map.permission :destroy_external_variables, {:lookup_keys => [:destroy],
                                                 :puppetclass_lookup_keys => [:destroy],
                                                 :variable_lookup_keys => [:destroy],
                                                 :lookup_values => [:destroy],
                                                 :"api/v1/lookup_keys" => [:destroy],
                                                 :"api/v2/smart_variables" => [:destroy],
                                                 :"api/v2/smart_class_parameters" => [:destroy],
                                                 :"api/v2/override_values" => [:create, :update, :destroy]}
  end

  permission_set.security_block :filters do |map|
    map.permission :view_filters,    {:filters => [:index, :auto_complete_search],
                                      :'api/v2/filters' => [:index, :show]}
    map.permission :create_filters,  {:filters => [:new, :create],
                                      :'api/v2/filters' => [:create]}
    map.permission :edit_filters,    {:filters => [:edit, :update], :permissions => [:index],
                                      :'api/v2/filters' => [:update],
                                      :'api/v2/permissions' => [:index, :show, :resource_types]}
    map.permission :destroy_filters, {:filters => [:destroy],
                                      :'api/v2/filters' => [:destroy]}
  end

  permission_set.security_block :global_variables do |map|
    map.permission :view_globals,    {:common_parameters => [:index, :show, :auto_complete_search],
                                      :"api/v1/common_parameters" => [:index, :show],
                                      :"api/v2/common_parameters" => [:index, :show]
    }
    map.permission :create_globals,  {:common_parameters => [:new, :create],
                                      :"api/v1/common_parameters" => [:create],
                                      :"api/v2/common_parameters" => [:create]
    }
    map.permission :edit_globals,    {:common_parameters => [:edit, :update],
                                      :"api/v1/common_parameters" => [:update],
                                      :"api/v2/common_parameters" => [:update]
    }
    map.permission :destroy_globals, {:common_parameters => [:destroy],
                                      :"api/v1/common_parameters" => [:destroy],
                                      :"api/v2/common_parameters" => [:destroy]
    }
  end

  permission_set.security_block :hostgroups do |map|
    ajax_actions = [:architecture_selected, :domain_selected, :environment_selected, :medium_selected, :os_selected,
                    :use_image_selected, :process_hostgroup, :current_parameters, :puppetclass_parameters]
    host_ajax_actions = [:process_hostgroup]
    pc_ajax_actions = [:parameters]

    map.permission :view_hostgroups,       {:hostgroups => [:index, :show, :auto_complete_search],
                                            :"api/v1/hostgroups" => [:index, :show],
                                            :"api/v2/hostgroups" => [:index, :show]
                                          }
    map.permission :create_hostgroups,     {:hostgroups => [:new, :create, :clone, :nest, :process_hostgroup].push(*ajax_actions),
                                            :host => host_ajax_actions,
                                            :puppetclasses => pc_ajax_actions,
                                            :"api/v1/hostgroups" => [:create, :clone],
                                            :"api/v2/hostgroups" => [:create, :clone]
                                          }
    map.permission :edit_hostgroups,       {:hostgroups => [:edit, :update, :architecture_selected, :process_hostgroup].push(*ajax_actions),
                                            :host => host_ajax_actions,
                                            :puppetclasses => pc_ajax_actions,
                                            :"api/v1/hostgroups" => [:update],
                                            :"api/v2/hostgroups" => [:update],
                                            :"api/v2/parameters" => [:create, :update, :destroy, :reset],
                                            :"api/v2/hostgroup_classes" => [:index, :create, :destroy]
                                           }
    map.permission :destroy_hostgroups,    {:hostgroups => [:destroy],
                                            :"api/v1/hostgroups" => [:destroy],
                                            :"api/v2/hostgroups" => [:destroy]
    }
  end

  permission_set.security_block :config_groups do |map|
    map.permission :view_config_groups,    {:config_groups => [:index, :auto_complete_search],
                                            :"api/v2/config_groups" => [:index, :show]
                                          }
    map.permission :create_config_groups,  {:config_groups => [:new, :create],
                                            :"api/v2/config_groups" => [:create]
                                          }
    map.permission :edit_config_groups,    {:config_groups => [:edit, :update],
                                            :"api/v2/config_groups" => [:update]
                                          }
    map.permission :destroy_config_groups, {:config_groups => [:destroy],
                                            :"api/v2/config_groups" => [:destroy]
                                          }
  end

  permission_set.security_block :hosts do |map|
    ajax_actions = [:architecture_selected, :compute_resource_selected, :domain_selected, :environment_selected,
                    :hostgroup_or_environment_selected, :medium_selected, :os_selected, :use_image_selected, :process_hostgroup,
                    :process_taxonomy, :current_parameters, :puppetclass_parameters, :template_used, :interfaces]
    cr_ajax_actions = [:cluster_selected, :template_selected, :provider_selected, :resource_pools]
    pc_ajax_actions = [:parameters]
    subnets_ajax_actions = [:freeip]
    tasks_ajax_actions = [:show]

    map.permission :view_hosts,    {:hosts => [:index, :show, :errors, :active, :out_of_sync, :disabled, :pending, :vm,
                                               :externalNodes, :pxe_config, :storeconfig_klasses, :auto_complete_search, :bmc,
                                               :runtime, :resources, :templates, :overview, :nics],
                                    :dashboard => [:OutOfSync, :errors, :active],
                                    :unattended => [:template, :provision],
                                     :"api/v1/hosts" => [:index, :show, :status],
                                     :"api/v2/hosts" => [:index, :show, :status, :get_status, :vm_compute_attributes, :template],
                                     :"api/v2/interfaces" => [:index, :show],
                                     :locations =>  [:mismatches],
                                     :organizations =>  [:mismatches]
                                  }
    map.permission :create_hosts,  {:hosts => [:new, :create, :clone].push(*ajax_actions),
                                    :compute_resources => cr_ajax_actions,
                                    :puppetclasses => pc_ajax_actions,
                                    :subnets => subnets_ajax_actions,
                                    :interfaces => [:new],
                                     :"api/v1/hosts" => [:create],
                                     :"api/v2/hosts" => [:create],
                                     :"api/v2/interfaces" => [:create],
                                     :"api/v2/tasks" => [:index]
                                  }
    map.permission :edit_hosts,    {:hosts => [:edit, :update, :multiple_actions, :reset_multiple, :submit_multiple_enable,
                                               :select_multiple_hostgroup, :select_multiple_environment, :submit_multiple_disable,
                                               :multiple_parameters, :multiple_disable, :multiple_enable, :update_multiple_environment,
                                               :update_multiple_hostgroup, :update_multiple_parameters, :toggle_manage,
                                               :select_multiple_organization, :update_multiple_organization,
                                               :disassociate, :multiple_disassociate, :update_multiple_disassociate,
                                               :select_multiple_owner, :update_multiple_owner,
                                               :select_multiple_location, :update_multiple_location].push(*ajax_actions),
                                    :compute_resources => [:associate].push(cr_ajax_actions),
                                    :compute_resources_vms => [:associate],
                                    :puppetclasses => pc_ajax_actions,
                                    :subnets => subnets_ajax_actions,
                                    :interfaces => [:new],
                                    :"api/v1/hosts" => [:update],
                                    :"api/v2/hosts" => [:update, :disassociate],
                                    :"api/v2/interfaces" => [:create, :update, :destroy],
                                    :"api/v2/compute_resources" => [:associate]
                                  }
    map.permission :destroy_hosts, {:hosts => [:destroy, :multiple_actions, :reset_multiple, :multiple_destroy, :submit_multiple_destroy],
                                    :"api/v1/hosts" => [:destroy],
                                    :"api/v2/hosts" => [:destroy],
                                    :"api/v2/interfaces" => [:destroy]
                                  }
    map.permission :build_hosts,   {:hosts => [:setBuild, :cancelBuild, :multiple_build, :submit_multiple_build, :review_before_build,
                                               :rebuild_config, :submit_rebuild_config],
                                    :tasks => tasks_ajax_actions,
                                    :"api/v2/tasks" => [:index],
                                    :"api/v2/hosts" => [:rebuild_config],
                                     }
    map.permission :power_hosts,   {:hosts          => [:power],
                                    :"api/v2/hosts" => [:power] }
    map.permission :console_hosts, {:hosts => [:console] }
    map.permission :ipmi_boot, { :hosts          => [:ipmi_boot],
                                 :"api/v2/hosts" => [:boot] }
    map.permission :puppetrun_hosts, {:hosts => [:puppetrun, :multiple_puppetrun, :update_multiple_puppetrun],
                                      :"api/v2/hosts" => [:puppetrun] }
  end

  permission_set.security_block :host_editing do |map|
    map.permission :edit_classes,   {:host_editing => [:edit_classes],
                                     :"api/v2/host_classes" => [:index, :create, :destroy]
                                    }
    map.permission :create_params,  {:host_editing => [:create_params],
                                     :"api/v2/parameters" => [:create]
    }
    map.permission :edit_params,    {:host_editing => [:edit_params],
                                     :"api/v2/parameters" => [:update]
    }
    map.permission :destroy_params, {:host_editing => [:destroy_params],
                                     :"api/v2/parameters" => [:destroy, :reset]
    }
  end

  permission_set.security_block :images do |map|
    map.permission :view_images,    {:images => [:index, :show, :auto_complete_search],
                                     :"api/v1/images" => [:index, :show],
                                     :"api/v2/images" => [:index, :show]
    }
    map.permission :create_images,  {:images => [:new, :create],
                                     :"api/v1/images" => [:create],
                                     :"api/v2/images" => [:create]
    }
    map.permission :edit_images,    {:images => [:edit, :update],
                                     :"api/v1/images" => [:update],
                                     :"api/v2/images" => [:update]
    }
    map.permission :destroy_images, {:images => [:destroy],
                                     :"api/v1/images" => [:destroy],
                                     :"api/v2/images" => [:destroy]
    }
  end

  if SETTINGS[:locations_enabled]
    permission_set.security_block :locations do |map|
      map.permission :view_locations, {:locations =>  [:index, :show, :auto_complete_search],
                                       :"api/v1/locations" => [:index, :show],
                                       :"api/v2/locations" => [:index, :show]
      }
      map.permission :create_locations, {:locations => [:new, :create, :clone_taxonomy, :step2, :nest],
                                       :"api/v1/locations" => [:create],
                                       :"api/v2/locations" => [:create]
                                     }
      map.permission :edit_locations, {:locations => [:edit, :update, :import_mismatches, :parent_taxonomy_selected],
                                       :"api/v1/locations" => [:update],
                                       :"api/v2/locations" => [:update]
      }
      map.permission :destroy_locations, {:locations => [:destroy],
                                       :"api/v1/locations" => [:destroy],
                                       :"api/v2/locations" => [:destroy]
      }
      map.permission :assign_locations, {:locations => [:assign_all_hosts, :assign_hosts, :assign_selected_hosts]}
    end
  end

  permission_set.security_block :mail_notifications do |map|
    map.permission :view_mail_notifications, { :mail_notifications => [:index, :auto_complete_search, :show],
                                               :"api/v2/mail_notifications" => [:index, :show] }
  end

  permission_set.security_block :media do |map|
    map.permission :view_media,    {:media => [:index, :show, :auto_complete_search],
                                   :"api/v1/media" => [:index, :show],
                                   :"api/v2/media" => [:index, :show]
    }
    map.permission :create_media,  {:media => [:new, :create],
                                   :"api/v1/media" => [:create],
                                   :"api/v2/media" => [:create]
    }
    map.permission :edit_media,    {:media => [:edit, :update],
                                   :"api/v1/media" => [:update],
                                   :"api/v2/media" => [:update]
    }
    map.permission :destroy_media, {:media => [:destroy],
                                   :"api/v1/media" => [:destroy],
                                   :"api/v2/media" => [:destroy]
    }
  end

  permission_set.security_block :models do |map|
    map.permission :view_models,    {:models => [:index, :show, :auto_complete_search],
                                     :"api/v1/models" => [:index, :show],
                                     :"api/v2/models" => [:index, :show]
    }
    map.permission :create_models,  {:models => [:new, :create],
                                     :"api/v1/models" => [:create],
                                     :"api/v2/models" => [:create]
    }
    map.permission :edit_models,    {:models => [:edit, :update],
                                     :"api/v1/models" => [:update],
                                     :"api/v2/models" => [:update]
    }
    map.permission :destroy_models, {:models => [:destroy],
                                     :"api/v1/models" => [:destroy],
                                     :"api/v2/models" => [:destroy]
    }
  end

  permission_set.security_block :operatingsystems do |map|
    map.permission :view_operatingsystems, { :operatingsystems => [:index, :show, :bootfiles, :auto_complete_search],
                                             :"api/v1/operatingsystems" => [:index, :show, :bootfiles],
                                             :"api/v2/operatingsystems" => [:index, :show, :bootfiles],
                                             :"api/v2/os_default_templates" => [:index, :show]
                                            }
    map.permission :create_operatingsystems, {:operatingsystems => [:new, :create],
                                             :"api/v1/operatingsystems" => [:create],
                                             :"api/v2/operatingsystems" => [:create],
                                             :"api/v2/os_default_templates" => [:create]
                                            }
    map.permission :edit_operatingsystems, {:operatingsystems => [:edit, :update],
                                       :"api/v1/operatingsystems" => [:update],
                                       :"api/v2/operatingsystems" => [:update],
                                       :"api/v2/parameters" => [:create, :update, :destroy, :reset],
                                       :"api/v2/os_default_templates" => [:create, :update, :destroy]
                                     }
    map.permission :destroy_operatingsystems, {:operatingsystems => [:destroy],
                                             :"api/v1/operatingsystems" => [:destroy],
                                             :"api/v2/operatingsystems" => [:destroy],
                                             :"api/v2/os_default_templates" => [:create]
                                              }
  end

  permission_set.security_block :partition_tables do |map|
    map.permission :view_ptables,    {:ptables => [:index, :show, :auto_complete_search, :revision, :preview],
                                      :"api/v1/ptables" => [:index, :show],
                                      :"api/v2/ptables" => [:index, :show, :revision]
    }
    map.permission :create_ptables,  {:ptables => [:new, :create, :clone_template],
                                      :"api/v1/ptables" => [:create],
                                      :"api/v2/ptables" => [:create, :clone]
    }
    map.permission :edit_ptables,    {:ptables => [:edit, :update],
                                      :"api/v1/ptables" => [:update],
                                      :"api/v2/ptables" => [:update]
    }
    map.permission :destroy_ptables, {:ptables => [:destroy],
                                      :"api/v1/ptables" => [:destroy],
                                      :"api/v2/ptables" => [:destroy]
    }
    map.permission :lock_ptables,    {:ptables => [:lock, :unlock],
                                       :"api/v2/ptables" => [:lock, :unlock]
                                      }
  end

  permission_set.security_block :puppetclasses do |map|
    map.permission :view_puppetclasses,    {:puppetclasses => [:index, :show, :auto_complete_search],
                                          :"api/v1/puppetclasses" => [:index, :show],
                                          :"api/v2/puppetclasses" => [:index, :show],
                                          :"api/v1/lookup_keys" => [:index, :show],
                                          :"api/v2/smart_variables" => [:index, :show],
                                          :"api/v2/smart_class_parameters" => [:index, :show],
                                        }
    map.permission :create_puppetclasses,  {:puppetclasses => [:new, :create],
                                          :"api/v1/puppetclasses" => [:create],
                                          :"api/v2/puppetclasses" => [:create]
                                        }
    map.permission :edit_puppetclasses,    {:puppetclasses => [:edit, :update, :override ],
                                          :"api/v1/puppetclasses" => [:update],
                                          :"api/v2/puppetclasses" => [:update],
                                          :"api/v1/lookup_keys" => [:create, :update, :destroy],
                                          :"api/v2/smart_variables" => [:create, :update, :destroy],
                                          :"api/v2/smart_class_parameters" => [:create, :update, :destroy]
                                        }
    map.permission :destroy_puppetclasses, {:puppetclasses => [:destroy],
                                          :"api/v1/puppetclasses" => [:destroy],
                                          :"api/v2/puppetclasses" => [:destroy]
                                        }
    map.permission :import_puppetclasses,  {:puppetclasses => [:import_environments, :obsolete_and_new],
                                           :"api/v1/environments" => [:import_puppetclasses],
                                           :"api/v2/environments" => [:import_puppetclasses],
                                           :"api/v1/smart_proxies" => [:import_puppetclasses],
                                           :"api/v2/smart_proxies" => [:import_puppetclasses]
                                            }
  end

  permission_set.security_block :roles do |map|
    map.permission :view_roles,    {:roles => [:index, :auto_complete_search],
                                    :'api/v2/roles' => [:index, :show]}
    map.permission :create_roles,  {:roles => [:new, :create, :clone],
                                    :'api/v2/roles' => [:create]}
    map.permission :edit_roles,    {:roles => [:edit, :update],
                                    :'api/v2/roles' => [:update]}
    map.permission :destroy_roles, {:roles => [:destroy],
                                    :'api/v2/roles' => [:destroy]}
  end

  permission_set.security_block :smart_proxies do |map|
    map.permission :view_smart_proxies,    {:smart_proxies => [:index, :ping, :auto_complete_search, :version,
                                                               :show, :plugin_version, :tftp_server],
                                          :"api/v1/smart_proxies" => [:index, :show],
                                          :"api/v2/smart_proxies" => [:index, :show, :version]
    }
    map.permission :create_smart_proxies,  {:smart_proxies => [:new, :create],
                                          :"api/v1/smart_proxies" => [:create],
                                          :"api/v2/smart_proxies" => [:create]
    }
    map.permission :edit_smart_proxies,    {:smart_proxies => [:edit, :update, :refresh],
                                          :"api/v1/smart_proxies" => [:update, :refresh],
                                          :"api/v2/smart_proxies" => [:update, :refresh]
    }
    map.permission :destroy_smart_proxies, {:smart_proxies => [:destroy],
                                          :"api/v1/smart_proxies" => [:destroy],
                                          :"api/v2/smart_proxies" => [:destroy]
    }
  end

  permission_set.security_block :smart_proxies_autosign do |map|
    map.permission :view_smart_proxies_autosign,    {:autosign => [:index, :show],
                                                     :"api/v1/autosign" => [:index],
                                                     :"api/v2/autosign" => [:index]
                                                    }
    map.permission :create_smart_proxies_autosign,  {:autosign => [:new, :create]}
    map.permission :destroy_smart_proxies_autosign, {:autosign => [:destroy]}
  end

  permission_set.security_block :smart_proxies_puppetca do |map|
    map.permission :view_smart_proxies_puppetca,    {:puppetca => [:index]}
    map.permission :edit_smart_proxies_puppetca,    {:puppetca => [:update]}
    map.permission :destroy_smart_proxies_puppetca, {:puppetca => [:destroy]}
  end

  permission_set.security_block :subnets do |map|
    map.permission :view_subnets,    {:subnets => [:index, :show, :auto_complete_search],
                                      :"api/v1/subnets" => [:index, :show],
                                      :"api/v2/subnets" => [:index, :show]
    }
    map.permission :create_subnets,  {:subnets => [:new, :create],
                                      :"api/v1/subnets" => [:create],
                                      :"api/v2/subnets" => [:create]
    }
    map.permission :edit_subnets,    {:subnets => [:edit, :update],
                                      :"api/v1/subnets" => [:update],
                                      :"api/v2/subnets" => [:update]
                                    }
    map.permission :destroy_subnets, {:subnets => [:destroy],
                                      :"api/v1/subnets" => [:destroy],
                                      :"api/v2/subnets" => [:destroy]
    }
    map.permission :import_subnets,  {:subnets => [:import, :create_multiple]}
  end

  if SETTINGS[:organizations_enabled]
    permission_set.security_block :organizations do |map|
      map.permission :view_organizations, {:organizations =>  [:index, :show, :auto_complete_search],
                                           :"api/v1/organizations" => [:index, :show],
                                           :"api/v2/organizations" => [:index, :show]
                                         }
      map.permission :create_organizations, {:organizations => [:new, :create, :clone_taxonomy, :step2, :nest],
                                           :"api/v1/organizations" => [:create],
                                           :"api/v2/organizations" => [:create]
      }
      map.permission :edit_organizations, {:organizations => [:edit, :update, :import_mismatches, :parent_taxonomy_selected],
                                           :"api/v1/organizations" => [:update],
                                           :"api/v2/organizations" => [:update]
      }
      map.permission :destroy_organizations, {:organizations => [:destroy],
                                           :"api/v1/organizations" => [:destroy],
                                           :"api/v2/organizations" => [:destroy]
      }
      map.permission :assign_organizations, {:organizations => [:assign_all_hosts, :assign_hosts, :assign_selected_hosts]}
    end
  end

  permission_set.security_block :usergroups do |map|
    map.permission :view_usergroups,    {:usergroups => [:index, :show, :auto_complete_search],
                                         :"api/v1/usergroups" => [:index, :show],
                                         :"api/v2/usergroups" => [:index, :show]
    }
    map.permission :create_usergroups,  {:usergroups => [:new, :create],
                                         :"api/v1/usergroups" => [:create],
                                         :"api/v2/usergroups" => [:create]
    }
    map.permission :edit_usergroups,    {:usergroups => [:edit, :update],
                                         :"api/v1/usergroups" => [:update],
                                         :"api/v2/usergroups" => [:update]
    }
    map.permission :destroy_usergroups, {:usergroups => [:destroy],
                                         :"api/v1/usergroups" => [:destroy],
                                         :"api/v2/usergroups" => [:destroy]
    }
  end

  permission_set.security_block :external_usergroups do |map|
    map.permission :view_external_usergroups, :external_usergroups => [:index, :show],
                                              :"api/v2/external_usergroups" => [:index, :show]
    map.permission :create_external_usergroups, :external_usergroups => [:new, :create],
                                                :"api/v2/external_usergroups" => [:new, :create]
    map.permission :edit_external_usergroups, :external_usergroups => [:edit, :update, :refresh],
                                                :"api/v2/external_usergroups" => [:update, :refresh]
    map.permission :destroy_external_usergroups, :external_usergroups => [:destroy],
                                                 :"api/v2/external_usergroups" => [:destroy]
  end

  permission_set.security_block :users do |map|
    ajax_actions = [:auth_source_selected, :test_mail]

    map.permission :view_users,
                   :users => [:index, :show, :auto_complete_search],
                   :"api/v1/users" => [:index, :show],
                   :"api/v2/users" => [:index, :show]
    map.permission :create_users,
                   :users => [:new, :create].push(*ajax_actions),
                   :"api/v1/users" => [:create],
                   :"api/v2/users" => [:create]
    map.permission :edit_users,
                   :users => [:edit, :update].push(*ajax_actions),
                   :"api/v1/users" => [:update],
                   :"api/v2/users" => [:update]
    map.permission :destroy_users,
                   :users => [:destroy],
                   :"api/v1/users" => [:destroy],
                   :"api/v2/users" => [:destroy]
  end

  permission_set.security_block :settings_menu do |map|
    map.permission :access_settings,  {:home => [:settings]}
  end

  permission_set.security_block :dashboard do |map|
    map.permission :access_dashboard, {:dashboard => [:index, :save_positions, :reset_default, :create, :destroy],
                                      :"api/v1/dashboard" => [:index],
                                      :"api/v2/dashboard" => [:index]
    }
  end

  permission_set.security_block :config_reports do |map|
    map.permission :view_config_reports, {:"api/v1/reports" => [:index, :show, :last],
                                          :"api/v2/reports" => [:index, :show, :last],
                                          :config_reports => [:index, :show, :auto_complete_search],
                                          :"api/v2/config_reports" => [:index, :show, :last]
                                       }
    map.permission :destroy_config_reports, {:config_reports => [:destroy],
                                             :"api/v1/reports" => [:destroy],
                                             :"api/v2/reports" => [:destroy],
                                             :"api/v2/config_reports" => [:destroy]
                                          }
    map.permission :upload_config_reports, {:"api/v2/reports" => [:create],
                                            :"api/v2/config_reports" => [:create]}
  end

  permission_set.security_block :facts do |map|
    map.permission :view_facts, {:facts       => [:index, :show],
                                :fact_values => [:index, :show, :auto_complete_search],
                                :"api/v1/fact_values" => [:index, :show],
                                :"api/v2/fact_values" => [:index, :show]
                              }
    map.permission :upload_facts, {:"api/v2/hosts" => [:facts] }
  end

  permission_set.security_block :audit_logs do |map|
    map.permission :view_audit_logs,  {:audits      => [:index, :show, :auto_complete_search],
                                       :"api/v1/audits" => [:index, :show],
                                       :"api/v2/audits" => [:index, :show]
    }
  end

  permission_set.security_block :statistics do |map|
    map.permission :view_statistics,  {:statistics  => [:index],
                                       :"api/v1/statistics" => [:index],
                                       :"api/v2/statistics" => [:index]
                                      }
  end

  permission_set.security_block :trends do |map|
    map.permission :view_trends,    {:trends => [:index, :show]}
    map.permission :create_trends,  {:trends => [:new, :create]}
    map.permission :edit_trends,    {:trends => [:edit, :update]}
    map.permission :destroy_trends, {:trends => [:destroy]}
    map.permission :update_trends,  {:trends => [:count]}
  end

  permission_set.security_block :tasks do |map|
    map.permission :view_tasks, {:trends => [:show]}
  end

  permission_set.security_block :plugins do |map|
    map.permission :view_plugins,    {:plugins => [:index],
                                      :"api/v2/plugins" => [:index]
    }
  end

  permission_set.security_block :anonymous do |map|
    map.permission :logout, {:users => [:logout]}, :public => true
  end
end
