ActionController::Routing::Routes.draw do |map|
  map.resources :usergroups
  map.root :controller => "hosts"

  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /[^\.][\w\.-]+/ }
  map.connect "/hosts/query", :controller => 'hosts', :action => 'query'
  map.resources :hosts,
                :member => { :report => :get, :reports => :get, :facts => :get, :clone => :get,
                  :environment_selected => :post, :architecture_selected => :post, :os_selected => :post,
                  :storeconfig_klasses => :get, :externalNodes => :get, :setBuild => :get, :puppetrun => :get},
                :collection => { :show_search => :get, :multiple_actions => :get, :multiple_parameters => :get,
                  :update_multiple_parameters => :post, :save_checkbox => :post, :select_multiple_hostgroup => :get,
                  :update_multiple_hostgroup => :post, :reset_multiple => :get}
  map.dashboard '/dashboard', :controller => 'dashboard'
  map.audit '/audit', :controller => 'audit'
  map.statistics '/statistics', :controller => 'statistics'
  map.settings '/settings', :controller => 'home', :action => 'settings'
  map.connect   "/reports/expire_reports", :controller => "reports", :action => "expire_reports"
  map.connect   "/reports/expire_good_reports", :controller => "reports", :action => "expire_good_reports"
  map.resources :reports, :active_scaffold => true
  map.resources :lookup_keys
  map.connect   "/lookup", :controller => "lookup_keys", :action => "q"
  map.resources :domains
  map.resources :operatingsystems
  map.resources :medias
  map.resources :models
  map.resources :architectures
  map.resources :puppetclasses, :member => { :assign => :post }
  map.import_classes '/puppetclass/import', :controller => 'puppetclasses', :action => 'import'
  map.resources :hostgroups
  map.resources :common_parameters
  map.resources :environments, :active_scaffold => true
  map.resources :subnets, :active_scaffold => true
  map.resources :fact_values, :active_scaffold => true
  map.resources :ptables
  map.resources :auth_source_ldaps
  map.login '/login', :controller => 'users', :action => 'login'
  map.logout '/logout', :controller => 'users', :action => 'logout'
  map.resources :users
  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
