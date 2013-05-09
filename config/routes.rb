require 'api_constraints'

Foreman::Application.routes.draw do
  #ENC requests goes here
  match "node/:name" => 'hosts#externalNodes', :constraints => { :name => /[^\.][\w\.-]+/ }
  post "reports/create"
  post "fact_values/create"

  resources :reports, :only => [:index, :show, :destroy, :create] do
    collection do
      get 'auto_complete_search'
    end
  end

  match '(:controller)/help', :action => 'welcome', :as => "help"
  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get 'clone'
        get 'storeconfig_klasses'
        get 'externalNodes'
        get 'setBuild'
        get 'cancelBuild'
        get 'puppetrun'
        get 'pxe_config'
        put 'toggle_manage'
        post 'environment_selected'
        put 'power'
        get 'console'
        get 'bmc'
        put 'ipmi_boot'
      end
      collection do
        get 'multiple_actions'
        get 'multiple_parameters'
        post 'update_multiple_parameters'
        get 'select_multiple_hostgroup'
        post 'update_multiple_hostgroup'
        get 'select_multiple_environment'
        post 'update_multiple_environment'
        get 'multiple_puppetrun'
        post 'update_multiple_puppetrun'
        get 'multiple_destroy'
        post 'submit_multiple_destroy'
        get 'multiple_build'
        post 'submit_multiple_build'
        get 'reset_multiple'
        get 'multiple_disable'
        post 'submit_multiple_disable'
        get 'multiple_enable'
        post 'submit_multiple_enable'
        get 'auto_complete_search'
        get 'template_used'
        get 'active'
        get 'pending'
        get 'out_of_sync'
        get 'errors'
        get 'disabled'
        post 'current_parameters'
        post 'puppetclass_parameters'
        post 'process_hostgroup'
        post 'process_taxonomy'
        post 'hostgroup_or_environment_selected'
        post 'architecture_selected'
        post 'os_selected'
        post 'domain_selected'
        post 'use_image_selected'
        post 'compute_resource_selected'
        post 'medium_selected'
        get  'select_multiple_organization'
        post 'update_multiple_organization'
        get  'select_multiple_location'
        post 'update_multiple_location'
      end

      constraints(:host_id => /[^\/]+/) do
        resources :reports       ,:only => [:index, :show]
        resources :audits        ,:only => :index
        resources :facts         ,:only => :index, :controller => :fact_values
        resources :puppetclasses ,:only => :index
        resources :lookup_keys   ,:only => :show
      end
    end


    resources :bookmarks, :except => [:show]
    resources :lookup_keys, :except => [:new, :create] do
      resources :lookup_values, :only => [:index, :create, :update, :destroy]
      collection do
        get 'auto_complete_search'
      end
    end

    resources :facts, :only => [:index, :show] do
      constraints(:id => /[^\/]+/) do
        resources :values, :only => :index, :controller => :fact_values, :as => "host_fact_values"
      end
    end

  end

  resources :settings, :only => [:index, :update] do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :common_parameters do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :environments do
    collection do
      get 'import_environments'
      post 'obsolete_and_new'
      get 'auto_complete_search'
    end
  end
  resources :trends do
    collection do
      post 'count'
    end
  end

  resources :hostgroups do
    member do
      get 'nest'
      get 'clone'
    end
    collection do
      get 'auto_complete_search'
      post 'environment_selected'
      post 'architecture_selected'
      post 'os_selected'
      post 'domain_selected'
      post 'use_image_selected'
      post 'medium_selected'
    end
  end

  resources :puppetclasses do
    collection do
      get 'import_environments'
      post 'obsolete_and_new'
      get 'auto_complete_search'
    end
    member do
      post 'parameters'
    end
    constraints(:id => /[^\/]+/) do
      resources :hosts
      resources :lookup_keys, :except => [:show, :new, :create]
    end
  end


  resources :smart_proxies, :except => [:show] do
    constraints(:id => /[^\/]+/) do
      resources :puppetca, :only => [:index, :update, :destroy]
      resources :autosign, :only => [:index, :new, :create, :destroy]
    end
  end

  resources :fact_values, :only => [:index] do
    collection do
      get 'auto_complete_search'
    end
  end

  resources :notices, :only => :destroy
  resources :audits do
    collection do
      get 'auto_complete_search'
    end
  end

  if SETTINGS[:login]
    resources :usergroups
    resources :users, :except => [:show] do
      collection do
        get 'login'
        post 'login'
        get 'logout'
        get 'auth_source_selected'
        get 'auto_complete_search'
      end
    end
    resources :roles do
      collection do
        get 'report'
        post 'report'
        get 'auto_complete_search'
      end
    end

    resources :auth_source_ldaps
  end

  if SETTINGS[:unattended]
    resources :config_templates do
      collection do
        get 'auto_complete_search'
        get 'build_pxe_default'
        get 'revision'
      end
    end
    constraints(:id => /[^\/]+/) do
      resources :domains do
        collection do
          get 'auto_complete_search'
        end
      end
    end

    resources :operatingsystems do
      member do
        get 'bootfiles'
      end
      collection do
        get 'auto_complete_search'
      end
    end
    resources :media do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :models do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :architectures do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :ptables do
      collection do
        get 'auto_complete_search'
      end
    end

    constraints(:id => /[^\/]+/) do
      resources :compute_resources do
        member do
          post 'hardware_profile_selected'
          post 'cluster_selected'
        end
        constraints(:id => /[^\/]+/) do
          resources :vms, :controller => "compute_resources_vms" do
            member do
              put 'power'
              get 'console'
            end
          end
        end
        collection do
          get  'auto_complete_search'
          get 'provider_selected'
          put  'test_connection'
        end
        resources :images
      end
    end

    resources :subnets, :except => [:show] do
      collection do
        get 'auto_complete_search'
        get 'import'
        post 'create_multiple'
        post 'freeip'
      end
    end

    match 'unattended/template/:id/:hostgroup', :to => "unattended#template"
  end

  root :to => 'dashboard#index'
  match 'dashboard', :to => 'dashboard#index', :as => "dashboard"
  match 'dashboard/auto_complete_search', :to => 'hosts#auto_complete_search', :as => "auto_complete_search_dashboards"
  match 'statistics', :to => 'statistics#index', :as => "statistics"
  match 'status', :to => 'home#status', :as => "status"

  # match for all unattended scripts
  match 'unattended/(:action/(:id(.format)))', :controller => 'unattended'

  resources :tasks, :only => [:show]

  if SETTINGS[:locations_enabled]
    resources :locations do
      resources :hosts, :only => :index
      member do
        get 'select'
        match "clone" => 'locations#clone_taxonomy'
        post 'import_mismatches'
        get 'step2'
        get 'assign_hosts'
        post 'assign_all_hosts'
        put 'assign_selected_hosts'
      end
      collection do
        get 'auto_complete_search'
        get 'clear'
        get  'mismatches'
        post 'import_mismatches'
      end
    end
  end

  if SETTINGS[:organizations_enabled]
    resources :organizations do
      member do
        get 'select'
        match "clone" => 'organizations#clone_taxonomy'
        post 'import_mismatches'
        get 'step2'
        get 'assign_hosts'
        post 'assign_all_hosts'
        put 'assign_selected_hosts'
      end
      collection do
        get 'auto_complete_search'
        get 'clear'
        get  'mismatches'
        post 'import_mismatches'
      end
    end
  end

end
