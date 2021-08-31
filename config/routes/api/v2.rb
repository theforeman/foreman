# config/routes/api/v2.rb
Foreman::Application.routes.draw do
  namespace :api, :defaults => {:format => 'json'} do
    puppet_plugin = Foreman::Plugin.find(:foreman_puppet)
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
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
      end

      resources :auth_source_externals, :only => [:index, :show, :update] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
        resources :external_usergroups, :except => [:new, :edit, :destroy]
        resources :users, :except => [:new, :edit, :destroy]
      end

      resources :auth_source_internals, :only => [:index, :show]

      resources :auth_source_ldaps, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
        resources :users, :except => [:new, :edit]
        resources :external_usergroups, :except => [:new, :edit]
      end

      resources :bookmarks, :except => [:new, :edit]

      resources :common_parameters, :except => [:new, :edit]

      resources :provisioning_templates, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
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

      resources :environments, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/environments' do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
        resources :smart_proxies, :only => [] do
          post :import_puppetclasses, :on => :member, :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
        end
        constraints(:id => /[^\/]+/) do
          resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
            resources :override_values, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
          end
          resources :puppetclasses, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/puppetclasses' do
            resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
              resources :override_values, :except => [:new, :edit, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
            end
          end
        end
        resources :hosts, :except => [:new, :edit]
        resources :template_combinations, :only => [:index, :show, :create, :update]
      end

      resources :fact_values, :only => [:index]

      resources :hostgroups, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
        post :clone, :on => :member
        put :rebuild_config, :on => :member
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :action => :reset
          end
        end
        constraints(:id => /[^\/]+/) do
          resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
            resources :override_values, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
          end
        end
        resources :puppetclasses, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/puppetclasses'
        resources :hostgroup_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/hostgroup_classes'
        resources :hosts, :except => [:new, :edit]
        resources :template_combinations, :only => [:show, :index, :create, :update]
      end

      resources :media, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
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
        resources :puppetclasses, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/puppetclasses'
        resources :os_default_templates, :except => [:new, :edit]
      end

      resources :templates, :only => :none do
        resources :template_inputs, :only => [:index, :show, :create, :destroy, :update]
      end

      resources :ptables, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
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

      resources :report_templates, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
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
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
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
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
      end

      resources :settings, :only => [:index, :show, :update]

      get '/', :to => 'home#index'
      get 'status', :to => 'home#status', :as => "v2_status"
      get 'current_user', to: 'users#show_current', as: "current_user"

      post :reports, :to => 'config_reports#create'

      resources :config_reports, :only => [:create]

      resources :http_proxies, :except => [:new, :edit]

      resources :subnets, :except => [:new, :edit] do
        resources :locations, :only => [:index, :show]
        resources :organizations, :only => [:index, :show]
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
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
          resources :roles, :except => [:new, :edit]
          resources :usergroups, :except => [:new, :edit]
          resources :ssh_keys, :only => [:index, :show, :create, :destroy]
          resources :personal_access_tokens, :only => [:index, :show, :create, :destroy]
          resources :table_preferences, :only => [:index, :create, :destroy, :show, :update]
          resources :mail_notifications, :only => [:create, :destroy, :update]
          get 'mail_notifications', :to => 'mail_notifications#user_mail_notifications', :on => :member
        end
      end

      resources :template_kinds, :only => [:index]

      resources :template_combinations, :only => [:show, :destroy]
      resources :config_groups, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/config_groups'

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
          get :available_virtual_machines, :on => :member
          get :available_clusters, :on => :member
          get :available_folders, :on => :member
          get :available_flavors, :on => :member
          get :available_networks, :on => :member
          get :available_vnic_profiles, :on => :member
          get :available_security_groups, :on => :member
          get :available_storage_domains, :on => :member
          get 'storage_domains/(:storage_domain_id)', :to => 'compute_resources#storage_domain', :on => :member
          get 'available_storage_domains/(:storage_domain)', :to => 'compute_resources#available_storage_domains', :on => :member
          get :available_storage_pods, :on => :member
          get 'storage_pods/(:storage_pod_id)', :to => 'compute_resources#storage_pod', :on => :member
          get 'available_virtual_machines/(:vm_id)', :to => 'compute_resources#show_vm', :on => :member
          get 'available_storage_pods/(:storage_pod)', :to => 'compute_resources#available_storage_pods', :on => :member
          get 'available_clusters/(:cluster_id)/available_networks', :to => 'compute_resources#available_networks', :on => :member, :cluster_id => /[^\/]+/
          get 'available_clusters/(:cluster_id)/available_resource_pools', :to => 'compute_resources#available_resource_pools', :on => :member, :cluster_id => /[^\/]+/
          get 'available_clusters/(:cluster_id)/available_storage_domains', :to => 'compute_resources#available_storage_domains', :on => :member, :cluster_id => /[^\/]+/
          get 'available_clusters/(:cluster_id)/available_storage_pods', :to => 'compute_resources#available_storage_pods', :on => :member, :cluster_id => /[^\/]+/
          get :available_zones, :on => :member
          put 'associate/(:vm_id)', :to => 'compute_resources#associate', :on => :member
          put :refresh_cache, :on => :member
          put 'available_virtual_machines/(:vm_id)/power', :to => 'compute_resources#power_vm', :on => :member
          delete 'available_virtual_machines/(:vm_id)', :to => 'compute_resources#destroy_vm', :on => :member
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
          resources :compute_attributes, :only => [:index, :show, :create, :update]
          resources :compute_profiles, :except => [:new, :edit] do
            resources :compute_attributes, :only => [:index, :show, :create, :update]
          end
        end

        resources :mail_notifications, :only => [:index, :show]

        resources :realms, :except => [:new, :edit] do
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
          resources :hosts, :except => [:new, :edit]
          resources :users, :except => [:new, :edit]
        end
        resources :domains, :except => [:new, :edit] do
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
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
          resources :locations, :only => [:index, :show]
          resources :organizations, :only => [:index, :show]
          put :refresh, :on => :member
          get :version, :on => :member
          get :logs, :on => :member
          post :import_puppetclasses, :on => :member, :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
          resources :environments, :only => [] do
            post :import_puppetclasses, :on => :member, :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
          end
          resources :autosign, :only => [:index, :create, :destroy]
        end
        resources :hosts, :except => [:new, :edit] do
          get :enc, :on => :member
          get 'status/:type', :on => :member, :action => :get_status
          get :vm_compute_attributes, :on => :member
          get 'template/:kind', :on => :member, :action => :template
          put :disassociate, :on => :member
          delete 'status/:type', :on => :member, :action => :forget_status
          put :boot, :on => :member
          get :power, :on => :member, :action => :power_status
          put :power, :on => :member
          put :rebuild_config, :on => :member
          post :facts, :on => :collection
          resources :audits, :only => :index
          resources :facts, :only => :index, :controller => :fact_values
          resources :host_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/host_classes'
          resources :interfaces, :except => [:new, :edit]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :action => :reset
            end
          end
          resources :puppetclasses, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/puppetclasses'

          resources :config_reports, :only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
            resources :override_values, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
          end
        end

        resources :puppetclasses, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/puppetclasses' do
          resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
            resources :override_values, :except => [:new, :edit, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
          end
          resources :environments, :only => [] do
            resources :smart_class_parameters, :except => [:new, :edit, :create], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
              resources :override_values, :except => [:new, :edit, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
            end
          end
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show], :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
        end

        resources :smart_class_parameters, :except => [:new, :edit, :create, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/smart_class_parameters' do
          resources :override_values, :except => [:new, :edit], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
        end

        resources :override_values, :only => [:update, :destroy], :controller => puppet_plugin && '/foreman_puppet/api/v2/override_values'
      end

      resources :locations, :except => [:new, :edit] do
        # scoped by location
        resources :auth_sources, :only => [:index, :show]
        resources :auth_source_ldaps, :only => [:index, :show]
        resources :auth_source_externals, :only => [:index, :show]
        resources :domains, :only => [:index, :show]
        resources :realms, :only => [:index, :show]
        resources :subnets, :only => [:index, :show]
        resources :hostgroups, :only => [:index, :show]
        resources :environments, :only => [:index, :show], :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
        resources :users, :only => [:index, :show]
        resources :provisioning_templates, :only => [:index, :show]
        resources :ptables, :only => [:index, :show]
        resources :compute_resources, :only => [:index, :show]
        resources :media, :only => [:index, :show]
        resources :smart_proxies, :only => [:index, :show]
        resources :filters, :only => [:index, :show]
        resources :hosts, :except => [:new, :edit]
        resources :report_templates, :only => [:index, :show]
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
          resources :environments, :only => [:index, :show], :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
          resources :users, :only => [:index, :show]
          resources :provisioning_templates, :only => [:index, :show]
          resources :ptables, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]
          resources :hosts, :except => [:new, :edit]
          resources :report_templates, :only => [:index, :show]
        end
      end

      resources :organizations, :except => [:new, :edit] do
        # scoped by organization
        resources :auth_sources, :only => [:index, :show]
        resources :auth_source_ldaps, :only => [:index, :show]
        resources :auth_source_externals, :only => [:index, :show]
        resources :domains, :only => [:index, :show]
        resources :realms, :only => [:index, :show]
        resources :subnets, :only => [:index, :show]
        resources :hostgroups, :only => [:index, :show]
        resources :environments, :only => [:index, :show], :controller => puppet_plugin && '/foreman_puppet/api/v2/environments'
        resources :users, :only => [:index, :show]
        resources :provisioning_templates, :only => [:index, :show]
        resources :ptables, :only => [:index, :show]
        resources :compute_resources, :only => [:index, :show]
        resources :media, :only => [:index, :show]
        resources :smart_proxies, :only => [:index, :show]
        resources :filters, :only => [:index, :show]
        resources :hosts, :except => [:new, :edit]
        resources :report_templates, :only => [:index, :show]
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
          resources :provisioning_templates, :only => [:index, :show]
          resources :ptables, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]
          resources :hosts, :except => [:new, :edit]
          resources :report_templates, :only => [:index, :show]
        end
      end

      get 'orchestration/(:id)/tasks', :to => 'tasks#index'
      resources :plugins, :only => [:index]
      get 'ping', :to => 'ping#ping'
      get 'statuses', :to => 'ping#statuses'
      put 'auth_source_ldaps/(:id)/test', :to => 'auth_source_ldaps#test'
      post 'registration_commands', to: 'registration_commands#create'
      get 'host_statuses', :to => 'host_statuses#index'
    end
  end
end
