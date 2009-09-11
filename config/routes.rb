ActionController::Routing::Routes.draw do |map|
  map.root :controller => "hosts"

  map.resources :domains, :active_scaffold => true
  map.resources :operatingsystems, :active_scaffold => true
  map.resources :medias, :active_scaffold => true
  map.resources :models, :active_scaffold => true
  map.resources :architectures, :active_scaffold => true
  map.resources :puppetclasses, :active_scaffold => true
  map.resources :hostgroups, :active_scaffold => true
  map.resources :commonParameters, :active_scaffold => true
  map.resources :environments, :active_scaffold => true
  map.connect "/hosts/externalNodes", :controller => 'hosts', :action => 'externalNodes'
  map.resources :hosts, :active_scaffold => true

  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
