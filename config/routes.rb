Foreman::Application.routes.draw do
  apipie_dsl
  resources :mail_notifications, only: [] do
    collection do
      get 'auto_complete_search'
    end
  end

  resources :config_reports, only: [:index, :show, :destroy] do
    collection do
      get 'auto_complete_search'
    end
  end

  welcoming_controllers = [
    'architectures',
    'auth_source_ldaps',
    'bookmarks',
    'common_parameters',
    'compute_profiles',
    'compute_resources',
    'config_reports',
    'domains',
    'fact_values',
    'hostgroups',
    'hosts',
    'http_proxies',
    'media',
    'models',
    'operatingsystems',
    'provisioning_templates',
    'ptables',
    'realms',
    'report_templates',
    'smart_proxies',
    'subnets',
    'usergroups',
  ]

  welcoming_controllers.each do |welcoming_controller|
    get "#{welcoming_controller}/help", action: :welcome, controller: welcoming_controller
  end

  constraints(id: /[^\/]+/) do
    resources :hosts do
      member do
        get 'clone'
        get 'review_before_build'
        put 'setBuild'
        get 'cancelBuild'
        get 'build_errors'
        get 'pxe_config'
        put 'toggle_manage'
        put 'power'
        get 'console'
        get 'overview'
        get 'bmc'
        get 'vm'
        get 'runtime'
        get 'resources'
        get 'templates'
        get 'nics'
        post 'forget_status'
        get 'statuses'
        put 'ipmi_boot'
        put 'disassociate'
      end
      collection do
        post 'multiple_actions'
        post 'multiple_parameters'
        post 'update_multiple_parameters'
        post 'select_multiple_hostgroup'
        post 'update_multiple_hostgroup'
        post 'select_multiple_owner'
        post 'update_multiple_owner'
        post 'select_multiple_power_state'
        post 'update_multiple_power_state'
        post 'select_multiple_puppet_ca_proxy'
        post 'update_multiple_puppet_ca_proxy'
        post 'multiple_destroy'
        post 'submit_multiple_destroy'
        post 'multiple_build'
        post 'submit_multiple_build'
        get 'reset_multiple'
        post 'multiple_disable'
        post 'submit_multiple_disable'
        post 'multiple_enable'
        post 'submit_multiple_enable'
        post 'multiple_disassociate'
        post 'update_multiple_disassociate'
        get 'auto_complete_search'
        post 'template_used'
        get 'active'
        get 'pending'
        get 'out_of_sync'
        get 'errors'
        get 'disabled'
        post 'current_parameters'
        post 'process_hostgroup'
        post 'process_taxonomy'
        post 'architecture_selected'
        post 'os_selected'
        post 'domain_selected'
        post 'use_image_selected'
        post 'compute_resource_selected'
        post 'scheduler_hint_selected'
        post 'interfaces'
        post 'medium_selected'
        post 'select_multiple_organization'
        post 'update_multiple_organization'
        post 'select_multiple_location'
        post 'update_multiple_location'
        post 'rebuild_config'
        post 'submit_rebuild_config'
        get 'random_name', only: :new
        get 'preview_host_collection'

        get 'register' => 'react#index'
        post 'register', to: 'registration_commands#create'
        get 'register/data', to: 'registration_commands#form_data'
        get 'register/os/:id', to: 'registration_commands#operatingsystem_template'
      end

      constraints(host_id: /[^\/]+/) do
        resources :config_reports, only: [:index, :show]
        resources :facts, only: :index, controller: :fact_values

        get 'parent_facts/*parent_fact/facts', to: 'fact_values#index', as: 'parent_fact_facts', parent_fact: /[\/\w.:_-]+/
      end
    end

    resources :bookmarks, except: [:show, :new, :create] do
      collection do
        get 'auto_complete_search'
      end
    end

    get 'parent_facts/:parent_fact/facts', to: 'fact_values#index', as: 'parent_fact_facts'
    resources :facts, only: [:index, :show] do
      constraints(id: /[^\/]+/) do
        resources :values, only: :index, controller: :fact_values, as: "host_fact_values"
      end
    end

    get 'unattended/template/:id/*hostgroup', to: "unattended#hostgroup_template", hostgroup: /.+/, format: 'text'
  end

  resources :settings, only: [:index, :update] do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :common_parameters, except: [:show] do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :parameters, only: [:index] do
    collection do
      get 'auto_complete_search'
    end
  end

  resources :compute_profiles do
    collection do
      get 'auto_complete_search'
    end
    resources :compute_attributes, only: [:create, :edit, :update]
    resources :compute_resources, only: [] do
      resources :compute_attributes, only: :new
    end
  end

  resources :hostgroups, except: [:show] do
    member do
      get 'nest'
      get 'clone'
    end
    collection do
      get 'auto_complete_search'
      post 'architecture_selected'
      post 'os_selected'
      post 'domain_selected'
      post 'use_image_selected'
      post 'medium_selected'
      post 'process_hostgroup'
    end
  end

  resources :smart_proxies do
    member do
      get 'ping'
      put 'refresh'
      get 'version'
      get 'plugin_version'
      get 'tftp_server'
      get 'log_pane'
      get 'failed_modules'
      get 'errors_card'
      get 'modules_card'
      post 'expire_logs'
    end
    constraints(id: /[^\/]+/) do
      resources :puppetca, only: [:index, :update, :destroy] do
        member do
          get 'counts'
          get 'expiry'
        end
      end
      resources :autosign, only: [:index, :new, :create, :destroy] do
        member do
          get 'counts'
        end
      end
    end
    collection do
      get 'auto_complete_search'
    end
  end

  resources :http_proxies, controller: 'http_proxies' do
    collection do
      get 'auto_complete_search'
      put 'test_connection'
    end
  end

  resources :fact_values, only: [:index] do
    collection do
      get 'auto_complete_search'
    end
  end

  resources :audits, only: [:index], constraints: ->(req) { req.format == :json }
  match '/audits/auto_complete_search' => 'audits#auto_complete_search', :via => [:get]
  match '/audits' => 'react#index', :via => [:get]

  resources :usergroups, except: [:show] do
    collection do
      get 'auto_complete_search'
    end
  end

  get 'menu', to: 'user_menus#menu'

  resources :users, except: [:show] do
    collection do
      get 'login'
      post 'login'
      get 'logout'
      post 'logout'
      get 'extlogin'
      get 'extlogout'
      get 'auto_complete_search'
      delete 'stop_impersonation'
    end
    member do
      post 'impersonate'
    end
    resources :ssh_keys, only: [:new, :create, :destroy]
  end
  resources :roles, except: [:show] do
    member do
      get 'clone'
      patch 'disable_filters_overriding'
    end
    collection do
      get 'auto_complete_search'
    end
  end

  resources :filters, except: [:show] do
    member do
      patch 'disable_overriding'
    end
    collection do
      get 'auto_complete_search'
    end
  end

  resources :permissions, only: [:index] do
    collection do
      get 'show_resource_types_with_translations'
    end
  end

  resources :auth_source_ldaps, except: [:show, :index] do
    collection do
      put 'test_connection'
    end
  end

  resources :auth_sources, only: [:show, :index]
  resources :auth_source_externals, only: [:update, :edit]

  put 'users/(:id)/test_mail', to: 'users#test_mail', as: 'test_mail_user'

  constraints(id: /[^\/]+/) do
    resources :external_usergroups, except: [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        put 'refresh'
      end
    end
  end

  scope 'templates' do
    resources :report_templates, except: [:show] do
      member do
        get 'clone_template'
        get 'lock'
        get 'unlock'
        get 'export'
        get 'generate'
        post 'schedule_report'
        post 'preview'
        get 'report_data'
      end
      collection do
        post 'preview'
        get 'revision'
        get 'auto_complete_search'
      end
    end
  end

  resources :provisioning_templates, only: [] do
    collection do
      get 'build_pxe_default'
    end
  end

  scope 'templates' do
    resources :ptables, except: [:show] do
      member do
        get 'clone_template'
        get 'lock'
        get 'unlock'
        get 'export'
        post 'preview'
      end
      collection do
        post 'preview'
        get 'revision'
        get 'auto_complete_search'
      end
    end

    resources :provisioning_templates, except: [:show] do
      member do
        get 'clone_template'
        get 'lock'
        get 'unlock'
        get 'export'
        post 'preview'
      end
      collection do
        post 'preview'
        get 'revision'
        get 'auto_complete_search'
      end
    end
  end

  constraints(id: /[^\/]+/) do
    resources :domains, except: [:show] do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :operatingsystems, except: [:show] do
      member do
        get 'bootfiles'
        get 'clone'
      end
      collection do
        get 'auto_complete_search'
      end
    end
  end

  resources :media, except: [:show] do
    member do
      get 'clone'
    end
    collection do
      get 'auto_complete_search'
    end
  end

  resources :models, except: [:show, :index] do
    collection do
      get 'auto_complete_search'
    end
  end
  match 'models' => 'react#index', :via => :get

  resources :architectures, except: [:show] do
    collection do
      get 'auto_complete_search'
    end
  end

  constraints(id: /[^\/]+/) do
    resources :compute_resources do
      member do
        post 'template_selected'
        post 'instance_type_selected'
        post 'cluster_selected'
        get 'resource_pools'
        post 'ping'
        put 'associate'
        put 'refresh_cache'
      end
      constraints(id: /[^\/]+/) do
        resources :vms, controller: "compute_resources_vms" do
          member do
            put 'power'
            put 'pause'
            put 'associate'
            get 'console'
            get 'import'
          end
        end
      end
      collection do
        get 'auto_complete_search'
        get 'provider_selected'
        put 'test_connection'
      end
      resources :images, except: [:show]
      resources :key_pairs, except: [:new, :edit, :update]
    end

    resources :realms, except: [:show] do
      collection do
        get 'auto_complete_search'
      end
    end
  end

  resources :subnets, except: [:show] do
    collection do
      get 'auto_complete_search'
      get 'import'
      post 'create_multiple'
      post 'freeip'
    end
  end

  resources :widgets, controller: 'dashboard', only: [:show, :create, :destroy] do
    collection do
      post 'save_positions', to: 'dashboard#save_positions'
      put 'reset_default', to: 'dashboard#reset_default'
    end
  end

  root to: 'dashboard#index'
  get 'dashboard', to: 'dashboard#index', as: "dashboard"
  get 'dashboard/auto_complete_search', to: 'hosts#auto_complete_search', as: "auto_complete_search_dashboard"
  get 'status', to: 'home#status', as: "status"

  # get only for alterator unattended scripts
  get 'unattended/provision/:metadata', controller: 'unattended', action: 'host_template', format: 'text',
    constraints: { metadata: /(autoinstall\.scm|vm-profile\.scm|pkg-groups\.tar)/ }
  # built call can be done both via GET (for backward compatibility) and POST
  get 'unattended/built/(:id(:format))', controller: 'unattended', action: 'built', format: 'text'
  post 'unattended/built/(:id(:format))', controller: 'unattended', action: 'built', format: 'text'
  # failed call only via POST
  post 'unattended/failed/(:id(:format))', controller: 'unattended', action: 'failed', format: 'text'
  # get for all unattended scripts
  get 'unattended/(:kind/(:id(:format)))', controller: 'unattended', action: 'host_template', format: 'text'

  get 'userdata/(:mac)/user-data', controller: 'userdata', action: 'userdata', format: 'text'
  get 'userdata/(:mac)/meta-data', controller: 'userdata', action: 'metadata', format: 'text'

  resources :tasks, only: [:show]

  resources :locations, except: [:show] do
    resources :hosts, only: :index
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

  resources :organizations, except: [:show] do
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

  resources :about, only: :index do
  end

  resources :interfaces, only: :new do
    collection do
      get :random_name
    end
  end

  resources :notification_recipients, only: [:index, :update, :destroy] do
    collection do
      put 'group/:group' => 'notification_recipients#update_group_as_read'
      delete 'group/:group' => 'notification_recipients#destroy_group'
    end
  end

  namespace :foreman_register do
    resources :hosts, only: [] do
      collection do
        get :register
      end
    end
  end

  get :register, to: 'api/v2/registration#global', as: :global_registration
  post :register, to: 'api/v2/registration#host'

  if Rails.env.development? && defined?(::GraphiQL::Rails::Engine)
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/api/graphql'
  end

  match 'host_statuses' => 'react#index', :via => :get
  constraints(id: /[^\/]+/) do
    match 'new/hosts/:id' => 'react#index', :via => :get, :as => :host_details_page
  end
  get 'page-not-found' => 'react#index'
  get 'links/:type(/:section)' => 'links#show', :as => 'external_link', :constraints => { section: %r{.*} }
end
