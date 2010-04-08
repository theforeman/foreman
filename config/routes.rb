ActionController::Routing::Routes.draw do |map|

  map.root :controller => "hosts"

  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /[^\.][\w\.-]+/ }
  map.connect "/hosts/query", :controller => 'hosts', :action => 'query'
  map.resources :hosts,
                :member => {:report => :get, :reports => :get, :facts => :get},
                :collection => { :show_search => :get},
                :active_scaffold => true
  map.connect   "/reports/expire_reports", :controller => "reports", :action => "expire_reports"
  map.connect   "/reports/expire_good_reports", :controller => "reports", :action => "expire_good_reports"
  map.resources :reports, :active_scaffold => true
  map.resources :lookup_keys
  map.connect   "/lookup", :controller => "lookup_keys", :action => "q"
  map.resources :domains, :active_scaffold => true
  map.resources :operatingsystems
  map.resources :medias, :active_scaffold => true
  map.resources :models, :active_scaffold => true
  map.resources :architectures
  map.resources :puppetclasses, :active_scaffold => true, :collection => {:import_classes_and_environments => :get}
  map.resources :hostgroups, :active_scaffold => true
  map.resources :common_parameters
  map.resources :environments, :active_scaffold => true,  :collection => {:import_classes_and_environments => :get}
  map.resources :subnets,          :active_scaffold => true
  map.resources :ptables
  map.resources :auth_sources
  map.login '/login', :controller => 'users', :action => 'login'
  map.logout '/logout', :controller => 'users', :action => 'logout'
  map.resources :users
  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
