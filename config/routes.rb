ActionController::Routing::Routes.draw do |map|
  map.root :controller => "hosts"

  map.resources :reports
  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /[^\.][\w\.-]+/ }
  map.resources :hosts,
    :requirements => {:id => /[^\/]+/},
    :member => { :report => :get, :reports => :get, :clone => :get,
      :environment_selected => :post, :architecture_selected => :post, :os_selected => :post,
      :storeconfig_klasses => :get, :externalNodes => :get, :setBuild => :get, :cancelBuild => :get, :puppetrun => :get, :facts => :get, :pxe_config => :get },
    :collection => { :show_search => :get, :multiple_actions => :get, :multiple_parameters => :get,
      :update_multiple_parameters => :post, :save_checkbox => :post, :select_multiple_hostgroup => :get,
      :update_multiple_hostgroup => :post, :select_multiple_environment => :get, :update_multiple_environment => :post,
      :multiple_destroy => :get, :submit_multiple_destroy => :post,
      :reset_multiple => :get, :multiple_disable => :get, :submit_multiple_disable => :post,
      :multiple_enable => :get, :submit_multiple_enable => :post,
      :query => :get, :active => :get, :out_of_sync => :get, :errors => :get, :disabled => :get
  }
  map.dashboard '/dashboard', :controller => 'dashboard'
  map.statistics '/statistics', :controller => 'statistics'
  map.resources :notices, :only => :destroy
  map.resources :audits
  map.resources :usergroups
  map.resources :lookup_keys
  map.connect   "/lookup", :controller => "lookup_keys", :action => "q"
  map.resources :domains, :requirements => {:id => /[^\/]+/}
  map.resources :operatingsystems, :member => {:bootfiles => :get}
  map.resources :media
  map.resources :models
  map.resources :architectures
  map.resources :puppetclasses, :member => { :assign => :post }, :collection => {:import_environments => :get}
  map.resources :hostgroups
  map.resources :common_parameters
  map.resources :environments, :collection => {:import_environments => :get, :obsolete_and_new => :post}
  map.resources :fact_values, :only => [:create, :index]
  map.resources :ptables
  map.resources :roles, :collection => {:report => [:get, :post]}
  map.resources :auth_source_ldaps
  map.resources :users, :collection => {:login => [:get, :post], :logout => :get, :auth_source_selected => :get}
  map.resources :config_templates, :except => [:show]
  map.resources :smart_proxies, :except => [:show]
  map.resources :subnets, :except => [:show]
  map.resources :hypervisors, :except => [:show]

  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
