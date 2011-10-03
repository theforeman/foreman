ActionController::Routing::Routes.draw do |map|
  map.root :controller => "dashboard"

  map.resources :reports,  :collection => { :auto_complete_search => :get }
  map.connect "node/:name", :controller => 'hosts', :action => 'externalNodes',
    :requirements => { :name => /[^\.][\w\.-]+/ }
  map.resources :hosts,
    :requirements => {:id => /[^\/]+/},
    :member => { :report => :get, :clone => :get, :toggle_manage => :put,
      :environment_selected => :post, :architecture_selected => :post, :os_selected => :post,
      :storeconfig_klasses => :get, :externalNodes => :get, :setBuild => :get, :cancelBuild => :get,
      :puppetrun => :get, :facts => :get, :pxe_config => :get },
    :collection => { :show_search => :get, :multiple_actions => :get, :multiple_parameters => :get,
      :update_multiple_parameters => :post, :select_multiple_hostgroup => :get,
      :update_multiple_hostgroup => :post, :select_multiple_environment => :get, :update_multiple_environment => :post,
      :multiple_destroy => :get, :submit_multiple_destroy => :post, :multiple_build => :get, :submit_multiple_build => :post,
      :reset_multiple => :get, :multiple_disable => :get, :submit_multiple_disable => :post,
      :multiple_enable => :get, :submit_multiple_enable => :post, :auto_complete_search => :get, :template_used => :get,
      :query => :get, :active => :get, :out_of_sync => :get, :errors => :get, :disabled => :get } do |hosts|
    hosts.resources :reports, :requirements => {:host_id => /[^\/]+/}, :only => [:index, :show]
    hosts.resources :facts, :requirements => {:host_id => /[^\/]+/}, :only => :index, :controller => :fact_values
    hosts.resources :puppetclasses, :requirements => {:host_id => /[^\/]+/}, :only => :index
    hosts.resources :lookup_keys, :requirements => {:host_id => /[^\/]+/}, :only => :show
  end
  map.dashboard '/dashboard', :controller => 'dashboard'
  map.dashboard_auto_completer '/dashboard/auto_complete_search', :controller => 'hosts', :action => :auto_complete_search
  map.statistics '/statistics', :controller => 'statistics'
  map.resources :notices, :only => :destroy
  map.resources :audits, :collection => {:auto_complete_search => :get}
  if SETTINGS[:login]
    map.resources :usergroups
    map.resources :users, :collection => {:login => [:get, :post], :logout => :get, :auth_source_selected => :get, :auto_complete_search => :get}
    map.resources :roles, :collection => {:report => [:get, :post], :auto_complete_search => :get}
  end

  if SETTINGS[:unattended]
    map.resources :domains, :requirements => {:id => /[^\/]+/}, :collection => {:auto_complete_search => :get}
    map.resources :operatingsystems, :member => {:bootfiles => :get}, :collection => {:auto_complete_search => :get}
    map.resources :media, :collection => {:auto_complete_search => :get}
    map.resources :models, :collection => {:auto_complete_search => :get}
    map.resources :architectures, :collection => {:auto_complete_search => :get}
    map.resources :ptables, :collection => {:auto_complete_search => :get}
    map.resources :config_templates, :except => [:show], :collection => { :auto_complete_search => :get }, :requirements => { :id => /[^\/]+/ }
    map.resources :subnets, :except => [:show], :collection => {:auto_complete_search => :get, :import => :get, :create_multiple => :post}
    map.connect 'unattended/template/:id/:hostgroup', :controller =>  "unattended", :action => "template"
  end

  map.resources :lookup_keys, :except => [:new, :create], :requirements => {:id => /[^\/]+/} do |keys|
    keys.resources :lookup_values, :only => [:index, :create, :update, :destroy]
  end
  map.resources :puppetclasses, :member => { :assign => :post }, :collection => {:import_environments => :get, :auto_complete_search => :get} do |pc|
    pc.resources :hosts, :requirements => {:id => /[^\/]+/}
    pc.resources :lookup_keys, :except => [:show, :new, :create], :requirements => {:id => /[^\/]+/}
  end
  map.resources :hostgroups, :member => { :nest => :get, :clone => :get }, :collection => { :auto_complete_search => :get }
  map.resources :common_parameters, :collection => {:auto_complete_search => :get}
  map.resources :environments, :collection => {:import_environments => :get, :obsolete_and_new => :post, :auto_complete_search => :get}
  map.resources :fact_values, :only => [:create, :index], :collection => { :auto_complete_search => :get }
  map.resources :facts, :only => [:index, :show], :requirements => {:id => /[^\/]+/} do |facts|
    facts.resources :values, :requirements => {:id => /[^\/]+/}, :only => :index, :controller => :fact_values
  end
  map.resources :auth_source_ldaps
  map.resources :smart_proxies, :except => [:show] do |proxy|
    proxy.resources :puppetca, :controller => "SmartProxies::Puppetca", :only => [:index, :update, :destroy], :requirements => { :id => /[^\.][\w\.-]+/ }
    proxy.resources :autosign, :controller => "SmartProxies::Autosign", :only => [:index, :new, :create, :destroy], :requirements => { :id => /[^\.][\w\.-]+/ }
  end
  map.resources :hypervisors, :requirements => { :id => /[^\/]+/ } do |hypervisor|
    hypervisor.resources :guests, :controller => "Hypervisors::Guests", :except => [:edit],
      :member => {:power => :put}, :requirements => { :id => /[^\.][\w\.-]+/ }
  end if SETTINGS[:libvirt]
  map.resources :bookmarks, :except => [:show], :requirements => { :id => /[^\/]+/ }
  map.resources :settings, :only => [:index, :update]
  map.connect '/status', :controller => "home", :action => "status"

  #default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
