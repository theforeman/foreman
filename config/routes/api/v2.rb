# config/routes/api/v2.rb
Foreman::Application.routes.draw do
  namespace :api, :defaults => {:format => 'json'} do
    # new v2 routes that point to v2
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'}, :apiv => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
      resources :architectures, :except => [:new, :edit] do
        constraints(:id => /[^\/]+/) do
          resources :hosts, :except => [:new, :edit]
        end
        resources :hostgroups, :except => [:new, :edit]
        resources :images, :except => [:new, :edit]
        resources :operatingsystems, :except => [:new, :edit]
      end

      resources :audits, :only => [:index, :show]

      resources :auth_sources, :only => [:index, :show] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :auth_source_externals, :only => [:index, :show, :update] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :external_usergroups, :except => [:new, :edit, :destroy]
        resources :users, :except => [:new, :edit, :destroy]
      end

      resources :auth_source_internals, :only => [:index, :show]

      resources :auth_source_ldaps, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :users, :except => [:new, :edit]
        resources :external_usergroups, :except => [:new, :edit]
      end

      resources :bookmarks, :except => [:new, :edit]

      resources :common_parameters, :except => [:new, :edit]

      resources :config_templates, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        post :clone, :on => :member
        collection do
          post 'build_pxe_default'
          get 'build_pxe_default' # Keeping get variant for backward compatibility, see #6976 for details
          get 'revision'
        end
        resources :template_combinations, :only => [:index, :create, :update, :show]
        resources :operatingsystems, :except => [:new, :edit]
        resources :os_default_templates, :except => [:new, :edit]
      end
      resources :provisioning_templates, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        member do
          post :clone
          get :export
        end
        collection do
          post 'build_pxe_default'
          get 'revision'
          post :import
        end
        resources :template_combinations, :only => [:index, :create, :update, :show]
        resources :operatingsystems, :except => [:new, :edit]
        resources :os_default_templates, :except => [:new, :edit]
      end

      resources :dashboard, :only => [:index]

      resources :environments, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :smart_proxies, :only => [] do
          post :import_puppetclasses, :on => :member
        end
        constraints(:id => /[^\/]+/) do
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :puppetclasses, :except => [:new, :edit] do
            resources :smart_class_parameters, :except => [:new, :edit, :create] do
              resources :override_values, :except => [:new, :edit, :destroy]
            end
          end
        end
        resources :hosts, :except => [:new, :edit]
        resources :template_combinations, :only => [:index, :show, :create, :update]
      end

      resources :fact_values, :only => [:index]

      resources :hostgroups, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        post :clone, :on => :member
        put :rebuild_config, :on => :member
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :action => :reset
          end
        end
        constraints(:id => /[^\/]+/) do
          resources :smart_variables, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
        resources :puppetclasses, :except => [:new, :edit]
        resources :hostgroup_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
        resources :hosts, :except => [:new, :edit]
        resources :template_combinations, :only => [:show, :index, :create, :update]
      end

      resources :media, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :operatingsystems, :except => [:new, :edit]
      end

      resources :models, :except => [:new, :edit]

      constraints(:id => /[^\/]+/) do
        resources :operatingsystems, :except => [:new, :edit] do
          get :bootfiles, :on => :member
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end
          resources :os_default_templates, :except => [:new, :edit]
          resources :ptables, :except => [:new, :edit]
          resources :architectures, :except => [:new, :edit]
          resources :config_templates, :except => [:new, :edit]
          resources :provisioning_templates, :except => [:new, :edit]
          resources :images, :except => [:new, :edit]
          resources :media, :only => [:index, :show]
        end
        resources :os_default_templates, :except => [:new, :edit]
        resources :hosts, :except => [:new, :edit]
        resources :hostgroups, :except => [:new, :edit]
        resources :media, :except => [:new, :edit]
        resources :ptables, :except => [:new, :edit]
        resources :architectures, :except => [:new, :edit]
        resources :puppetclasses, :except => [:new, :edit]
        resources :config_templates, :except => [:new, :edit]
        resources :os_default_templates, :except => [:new, :edit]
      end

      resources :templates, :only => :none do
        resources :template_inputs, :only => [:index, :show, :create, :destroy, :update]
      end

      resources :ptables, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        member do
          post :clone
          get :export
        end
        collection do
          get 'revision'
          post :import
        end

        resources :operatingsystems, :except => [:new, :edit]
      end

      resources :reports, :only => [:index, :show, :destroy] do
        get :last, :on => :collection
      end

      resources :report_templates, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        member do
          post :clone, :generate, :schedule_report
          get :export
          get 'report_data/:job_id', action: 'report_data', as: 'report_data'
        end
        collection do
          get 'revision'
          post :import
        end
      end

      resources :config_reports, :only => [:index, :show, :destroy] do
        get :last, :on => :collection
      end

      resources :roles, :except => [:new, :edit] do
        resources :filters, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
        resources :users, :except => [:new, :edit]
        member do
          post :clone
        end
      end
      resources :permissions, :only => [:index, :show] do
        collection do
          get :resource_types
        end
      end

      resources :filters, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :settings, :only => [:index, :show, :update]

      resources :statistics, :only => [:index]

      get '/', :to => 'home#index'
      get 'status', :to => 'home#status', :as => "v2_status"

      resources :reports, :only => [:create]

      resources :config_reports, :only => [:create]

      resources :http_proxies, :except => [:new, :edit]

      resources :trends, :only => [:create, :index, :show, :destroy]

      resources :subnets, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :domains, :except => [:new, :edit]
        resources :interfaces, :except => [:new, :edit]
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :action => :reset
          end
        end
        get :freeip, :on => :member
      end

      resources :usergroups, :except => [:new, :edit] do
        resources :users, :except => [:new, :edit]
        resources :usergroups, :except => [:new, :edit]
      end

      resources :usergroups, :except => [:new, :edit] do
        resources :external_usergroups, :except => [:new, :edit] do
          put :refresh, :on => :member
        end
      end

      # add "constraint" that unconstrained and allows :id to have dot notation ex. first.lastname
      constraints(:id => /[^\/]+/) do
        resources :users, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :roles, :except => [:new, :edit]
          resources :usergroups, :except => [:new, :edit]
          resources :ssh_keys, :only => [:index, :show, :create, :destroy]
          resources :personal_access_tokens, :only => [:index, :show, :create, :destroy]
          resources :table_preferences, :only => [:index, :create, :destroy, :show, :update]
        end
      end

      resources :template_kinds, :only => [:index]

      resources :template_combinations, :only => [:show, :destroy]
      resources :config_groups, :except => [:new, :edit]

      resources :compute_attributes, :only => [:index, :show, :create, :update]

      resources :compute_profiles, :except => [:new, :edit] do
        resources :compute_attributes, :only => [:index, :show, :create, :update]
        resources :compute_resources, :except => [:new, :edit] do
          resources :compute_attributes, :only => [:index, :show, :create, :update]
        end
      end

      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :compute_resources, :except => [:new, :edit] do
          resources :images, :except => [:new, :edit]
          get :available_images, :on => :member
          get :available_clusters, :on => :member
          get :available_folders, :on => :member
          get :available_flavors, :on => :member
          get :available_networks, :on => :member
          get :available_security_groups, :on => :member
          get :available_storage_domains, :on => :member
          get 'storage_domains/(:storage_domain_id)', :to => 'compute_resources#storage_domain', :on => :member
          get 'available_storage_domains/(:storage_domain)', :to => 'compute_resources#available_storage_domains', :on => :member
          get :available_storage_pods, :on => :member
          get 'storage_pods/(:storage_pod_id)', :to => 'compute_resources#storage_pod', :on => :member
          get 'available_storage_pods/(:storage_pod)', :to => 'compute_resources#available_storage_pods', :on => :member
          get 'available_clusters/(:cluster_id)/available_networks', :to => 'compute_resources#available_networks', :on => :member
          get 'available_clusters/(:cluster_id)/available_resource_pools', :to => 'compute_resources#available_resource_pools', :on => :member
          get 'available_clusters/(:cluster_id)/available_storage_domains', :to => 'compute_resources#available_storage_domains', :on => :member
          get 'available_clusters/(:cluster_id)/available_storage_pods', :to => 'compute_resources#available_storage_pods', :on => :member
          get :available_zones, :on => :member
          put :associate, :on => :member
          put :refresh_cache, :on => :member
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :compute_attributes, :only => [:index, :show, :create, :update]
          resources :compute_profiles, :except => [:new, :edit] do
            resources :compute_attributes, :only => [:index, :show, :create, :update]
          end
        end

        resources :mail_notifications, :only => [:index, :show]

        resources :realms, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :hosts, :except => [:new, :edit]
          resources :users, :except => [:new, :edit]
        end
        resources :domains, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end
          resources :hosts, :except => [:new, :edit]
          resources :hostgroups, :except => [:new, :edit]
          resources :subnets, :except => [:new, :edit]
          resources :users, :except => [:new, :edit]
          resources :interfaces, :except => [:new, :edit]
        end
        resources :smart_proxies, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          put :refresh, :on => :member
          get :version, :on => :member
          get :logs, :on => :member
          post :import_puppetclasses, :on => :member
          resources :environments, :only => [] do
            post :import_puppetclasses, :on => :member
          end
          resources :autosign, :only => [:index, :create, :destroy]
        end
        resources :hosts, :except => [:new, :edit] do
          get :enc, :on => :member
          get :status, :on => :member
          get 'status/:type', :on => :member, :action => :get_status
          get :vm_compute_attributes, :on => :member
          get 'template/:kind', :on => :member, :action => :template
          put :disassociate, :on => :member
          put :boot, :on => :member
          get :power, :on => :member, :action => :power_status
          put :power, :on => :member
          put :rebuild_config, :on => :member
          post :facts, :on => :collection
          resources :audits, :only => :index
          resources :facts, :only => :index, :controller => :fact_values
          resources :host_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
          resources :interfaces, :except => [:new, :edit]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end
          resources :puppetclasses, :except => [:new, :edit]
          resources :reports, :only => [:index, :show] do
            get :last, :on => :collection
          end

          resources :config_reports, :only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :smart_variables, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end

        resources :puppetclasses, :except => [:new, :edit] do
          resources :smart_variables, :except => [:new, :edit] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit, :destroy]
          end
          resources :environments, :only => [] do
            resources :smart_class_parameters, :except => [:new, :edit, :create] do
              resources :override_values, :except => [:new, :edit, :destroy]
            end
          end
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
        end

        resources :smart_variables, :except => [:new, :edit] do
          resources :override_values, :except => [:new, :edit]
        end

        resources :smart_class_parameters, :except => [:new, :edit, :create, :destroy] do
          resources :override_values, :except => [:new, :edit]
        end

        resources :override_values, :only => [:update, :destroy]
      end

      if SETTINGS[:locations_enabled]
        resources :locations, :except => [:new, :edit] do
          # scoped by location
          resources :auth_sources, :only => [:index, :show]
          resources :auth_source_ldaps, :only => [:index, :show]
          resources :auth_source_externals, :only => [:index, :show]
          resources :domains, :only => [:index, :show]
          resources :realms, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :provisioning_templates, :only => [:index, :show]
          resources :ptables, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]
          resources :hosts, :except => [:new, :edit]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end

          # scoped by location AND organization
          resources :organizations, :except => [:new, :edit] do
            resources :auth_sources, :only => [:index, :show]
            resources :auth_source_ldaps, :only => [:index, :show]
            resources :auth_source_externals, :only => [:index, :show]
            resources :domains, :only => [:index, :show]
            resources :realms, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :provisioning_templates, :only => [:index, :show]
            resources :ptables, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
            resources :filters, :only => [:index, :show]
            resources :hosts, :except => [:new, :edit]
          end
        end
      end

      if SETTINGS[:organizations_enabled]
        resources :organizations, :except => [:new, :edit] do
          # scoped by organization
          resources :auth_sources, :only => [:index, :show]
          resources :auth_source_ldaps, :only => [:index, :show]
          resources :auth_source_externals, :only => [:index, :show]
          resources :domains, :only => [:index, :show]
          resources :realms, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :provisioning_templates, :only => [:index, :show]
          resources :ptables, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]
          resources :hosts, :except => [:new, :edit]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end

          # scoped by location AND organization
          resources :locations, :except => [:new, :edit] do
            resources :auth_sources, :only => [:index, :show]
            resources :auth_source_ldaps, :only => [:index, :show]
            resources :auth_source_externals, :only => [:index, :show]
            resources :domains, :only => [:index, :show]
            resources :realms, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :provisioning_templates, :only => [:index, :show]
            resources :ptables, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
            resources :filters, :only => [:index, :show]
            resources :hosts, :except => [:new, :edit]
          end
        end
      end
      get 'orchestration/(:id)/tasks', :to => 'tasks#index'
      resources :plugins, :only => [:index]
      put 'auth_source_ldaps/(:id)/test', :to => 'auth_source_ldaps#test'
    end
  end
end
