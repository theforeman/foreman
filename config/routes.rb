require 'api_constraints'

Foreman::Application.routes.draw do
  resources :mail_notifications, :only => [] do
    collection do
      get 'auto_complete_search'
    end
  end

  #ENC requests goes here
  get "node/:name" => 'hosts#externalNodes', :constraints => { :name => /[^\.][\w\.-]+/ }

  resources :config_reports, :only => [:index, :show, :destroy] do
    collection do
      get 'auto_complete_search'
    end
  end

  get '(:controller)/help', :action => 'welcome', :as => "help"
  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get 'clone'
        get 'storeconfig_klasses'
        get 'externalNodes'
        get 'review_before_build'
        put 'setBuild'
        get 'cancelBuild'
        get 'puppetrun'
        get 'pxe_config'
        put 'toggle_manage'
        post 'environment_selected'
        put 'power'
        get 'console'
        get 'overview'
        get 'bmc'
        get 'vm'
        get 'runtime'
        get 'resources'
        get 'templates'
        get 'nics'
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
        get 'select_multiple_owner'
        post 'update_multiple_owner'
        get 'select_multiple_power_state'
        post 'update_multiple_power_state'
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
        post 'interfaces'
        post 'medium_selected'
        get  'select_multiple_organization'
        post 'update_multiple_organization'
        get  'select_multiple_location'
        post 'update_multiple_location'
        get  'rebuild_config'
        post 'submit_rebuild_config'
      end

      constraints(:host_id => /[^\/]+/) do
        resources :config_reports, :only => [:index, :show]
        resources :audits, :only => :index
        resources :facts, :only => :index, :controller => :fact_values
        resources :puppetclasses, :only => :index
      end
    end

    resources :bookmarks, :except => [:show]
    [:lookup_keys, :variable_lookup_keys, :puppetclass_lookup_keys].each do |key|
      resources key, :except => [:show, :new, :create] do
        resources :lookup_values, :only => [:index, :create, :update, :destroy]
        collection do
          get 'auto_complete_search'
        end
      end
    end

    resources :facts, :only => [:index, :show] do
      constraints(:id => /[^\/]+/) do
        resources :values, :only => :index, :controller => :fact_values, :as => "host_fact_values"
      end
    end

    constraints(:hostgroup => /[^\/]+/) do
      get 'unattended/template/:id/:hostgroup', :to => "unattended#hostgroup_template"
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
      post 'puppetclass_parameters'
    end
  end

  resources :config_groups, :except => [:show] do
    get 'auto_complete_search', :on => :collection
  end

  resources :puppetclasses, :except => [:new, :create, :show] do
    collection do
      get 'import_environments'
      post 'obsolete_and_new'
      get 'auto_complete_search'
    end
    member do
      post 'parameters'
      post 'override'
    end
    constraints(:id => /[^\/]+/) do
      resources :hosts
      resources :lookup_keys, :except => [:show, :new, :create]
    end
  end

  resources :smart_proxies do
    member do
      get 'ping'
      put 'refresh'
      get 'version'
      get 'plugin_version'
      get 'tftp_server'
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
        post 'logout'
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

    resources :auth_source_ldaps, :except => [:show] do
      collection do
        put 'test_connection'
      end
    end

    put 'users/(:id)/test_mail', :to => 'users#test_mail', :as => 'test_mail_user'

    resources :external_usergroups, :except => [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        put 'refresh'
      end
    end
  end

  if SETTINGS[:unattended]
    resources :provisioning_templates, :only => [] do
      collection do
        get 'build_pxe_default'
      end
    end

    scope 'templates' do
      resources :ptables, :except => [:show] do
        member do
          get 'clone_template'
          get 'lock'
          get 'unlock'
          post 'preview'
        end
        collection do
          post 'preview'
          get 'revision'
          get 'auto_complete_search'
        end
      end

      resources :provisioning_templates, :except => [:show] do
        member do
          get 'clone_template'
          get 'lock'
          get 'unlock'
          post 'preview'
        end
        collection do
          post 'preview'
          get 'revision'
          get 'auto_complete_search'
        end
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

    constraints(:id => /[^\/]+/) do
      resources :compute_resources do
        member do
          post 'template_selected'
          post 'cluster_selected'
          get 'resource_pools'
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

      resources :realms, :except => [:show] do
        collection do
          get 'auto_complete_search'
        end
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

  end

  resources :widgets, :controller => 'dashboard', :only => [:create, :destroy] do
    collection do
      post 'save_positions', :to => 'dashboard#save_positions'
      put 'reset_default', :to => 'dashboard#reset_default'
    end
  end

  root :to => 'dashboard#index'
  get 'dashboard', :to => 'dashboard#index', :as => "dashboard"
  get 'dashboard/auto_complete_search', :to => 'hosts#auto_complete_search', :as => "auto_complete_search_dashboards"
  get 'statistics', :to => 'statistics#index', :as => "statistics"
  get 'status', :to => 'home#status', :as => "status"

  # get only for alterator unattended scripts
  get 'unattended/provision/:metadata', :controller => 'unattended', :action => 'host_template', :format => 'html',
    :constraints => { :metadata => /(autoinstall\.scm|vm-profile\.scm|pkg-groups\.tar)/ }
  # get for end of build action
  get 'unattended/built/(:id(:format))', :controller => 'unattended', :action => 'built'
  # get for all unattended scripts
  get 'unattended/(:kind/(:id(:format)))', :controller => 'unattended', :action => 'host_template'

  resources :tasks, :only => [:show]

  if SETTINGS[:locations_enabled]
    resources :locations, :except => [:show] do
      resources :hosts, :only => :index
      member do
        get 'select'
        get "clone" => 'locations#clone_taxonomy'
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
        get "clone" => 'organizations#clone_taxonomy'
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

  resources :interfaces, :only => :new
end
