require 'api_constraints'

Foreman::Application.routes.draw do
  #ENC requests goes here
  match "node/:name" => 'hosts#externalNodes', :constraints => { :name => /[^\.][\w\.-]+/ }

  resources :reports, :only => [:index, :show, :destroy] do
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
        get 'vm'
        put 'ipmi_boot'
        put 'disassociate'
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
        get 'multiple_disassociate'
        post 'update_multiple_disassociate'
        get 'auto_complete_search'
        post 'template_used'
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
      end
    end


    resources :bookmarks, :except => [:show]
    resources :lookup_keys, :except => [:show, :new, :create] do
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
  resources :common_parameters, :except => [:show] do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :environments, :except => [:show] do
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

  resources :compute_profiles do
    resources :compute_attributes, :only => [:create, :edit, :update]
    resources :compute_resources, :only => [] do
      resources :compute_attributes, :only => :new
    end
  end

  resources :hostgroups, :except => [:show] do
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
      post 'process_hostgroup'
    end
  end

  resources :config_groups, :except => [:show] do
    get 'auto_complete_search', :on => :collection
  end

  resources :puppetclasses, :except => [:show] do
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
    member do
      post 'ping'
      put 'refresh'
    end
    constraints(:id => /[^\/]+/) do
      resources :puppetca, :only => [:index, :update, :destroy]
      resources :autosign, :only => [:index, :new, :create, :destroy]
    end
    collection do
      get 'auto_complete_search'
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
    resources :usergroups, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end
    resources :users, :except => [:show] do
      collection do
        get 'login'
        post 'login'
        get 'logout'
        get 'extlogin'
        get 'extlogout'
        get 'auth_source_selected'
        get 'auto_complete_search'
      end
    end
    resources :roles, :except => [:show] do
      member do
        get 'clone'
      end
      collection do
        get 'auto_complete_search'
      end
    end

    resources :filters, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :permissions, :only => [:index]

    resources :auth_source_ldaps, :except => [:show]
  end

  if SETTINGS[:unattended]
    resources :config_templates, :except => [:show] do
      collection do
        get 'auto_complete_search'
        get 'build_pxe_default'
        get 'revision'
      end
    end
    constraints(:id => /[^\/]+/) do
      resources :domains, :except => [:show] do
        collection do
          get 'auto_complete_search'
        end
      end

      resources :operatingsystems, :except => [:show] do
        member do
          get 'bootfiles'
        end
        collection do
          get 'auto_complete_search'
        end
      end
    end
    resources :media, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :models, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :architectures, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :ptables, :except => [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    constraints(:id => /[^\/]+/) do
      resources :compute_resources do
        member do
          post 'template_selected'
          post 'cluster_selected'
          post 'ping'
          put 'associate'
        end
        constraints(:id => /[^\/]+/) do
          resources :vms, :controller => "compute_resources_vms" do
            member do
              put 'power'
              put 'pause'
              put 'associate'
              get 'console'
            end
          end
        end
        collection do
          get  'auto_complete_search'
          get 'provider_selected'
          put  'test_connection'
        end
        resources :images, :except => [:show]
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

    resources :realms, :except => [:show] do
      collection do
        get 'auto_complete_search'
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
    resources :locations, :except => [:show] do
      resources :hosts, :only => :index
      member do
        get 'select'
        match "clone" => 'locations#clone_taxonomy'
        get 'nest'
        post 'import_mismatches'
        get 'step2'
        get 'assign_hosts'
        post 'assign_all_hosts'
        put 'assign_selected_hosts'
        post 'parent_taxonomy_selected'
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
    resources :organizations, :except => [:show] do
      member do
        get 'select'
        match "clone" => 'organizations#clone_taxonomy'
        get 'nest'
        post 'import_mismatches'
        get 'step2'
        get 'assign_hosts'
        post 'assign_all_hosts'
        put 'assign_selected_hosts'
        post 'parent_taxonomy_selected'
      end
      collection do
        get 'auto_complete_search'
        get 'clear'
        get  'mismatches'
        post 'import_mismatches'
      end
    end
  end

  resources :about, :only => :index do
  end

end
