ActionController::Routing::Routes.draw do |map|
  map.root :controller => "hosts"

  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /(\w+\.)+\w+/ }
  map.connect "/hosts/query", :controller => 'hosts', :action => 'query'
  map.resources :hosts, :member => {:report => :get, :reports => :get}, :collection => { :show_search => :get}, :active_scaffold => true
  map.connect   "/reports/expire_reports", :controller => "reports", :action => "expire_reports"
  map.resources :reports, :active_scaffold => true
  map.resources :domains, :active_scaffold => true
  map.resources :operatingsystems, :active_scaffold => true
  map.resources :medias, :active_scaffold => true
  map.resources :models, :active_scaffold => true
  map.resources :architectures, :active_scaffold => true
  map.resources :puppetclasses, :active_scaffold => true
  map.resources :hostgroups, :active_scaffold => true
  map.resources :common_parameters, :active_scaffold => true
  map.resources :environments, :active_scaffold => true

  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
