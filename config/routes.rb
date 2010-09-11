ActionController::Routing::Routes.draw do |map|
  map.root :controller => "hosts"

  map.resources :reports
  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /[^\.][\w\.-]+/ }
  map.connect "/hosts/query", :controller => 'hosts', :action => 'query'
  map.resources :hosts,
                :member => { :report => :get, :reports => :get, :clone => :get,
                  :environment_selected => :post, :architecture_selected => :post, :os_selected => :post,
                  :storeconfig_klasses => :get, :externalNodes => :get, :setBuild => :get, :cancelBuild => :get, :puppetrun => :get},
                :collection => { :show_search => :get, :multiple_actions => :get, :multiple_parameters => :get,
                  :update_multiple_parameters => :post, :save_checkbox => :post, :select_multiple_hostgroup => :get,
                  :update_multiple_hostgroup => :post, :select_multiple_environment => :get, :update_multiple_environment => :post,
                  :multiple_destroy => :get, :submit_multiple_destroy => :post,
                  :reset_multiple => :get, :multiple_disable => :get, :submit_multiple_disable => :post,
                  :multiple_enable => :get, :submit_multiple_enable => :post,}
  map.dashboard '/dashboard', :controller => 'dashboard'
  map.statistics '/statistics', :controller => 'statistics'
  map.resources :audits
  map.resources :usergroups
  map.resources :lookup_keys
  map.connect   "/lookup", :controller => "lookup_keys", :action => "q"
  map.resources :domains
  map.resources :operatingsystems
  map.resources :medias
  map.resources :models
  map.resources :architectures
  map.resources :puppetclasses, :member => { :assign => :post }, :collection => {:import_environments => :get}
  map.resources :hostgroups
  map.resources :common_parameters
  map.resources :environments, :collection => {:import_environments => :get, :obsolete_and_new => :post}
  map.resources :fact_values
  map.resources :ptables
  map.resources :auth_source_ldaps
  map.resources :users, :collection => {:login => [:get, :post], :logout => :get, :auth_source_selected => :get}
  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
