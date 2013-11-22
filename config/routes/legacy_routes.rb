require 'api_constraints'

Foreman::Application.routes.draw do

  constraints(:id => /[^\/]+/) do
    # Add :as => :old_**** to legacy routes (i.e. routes in with :path => alias_name) to avoid clashes with named URL route helpers
    resources :hosts, :as => :old_hosts do
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
        put 'ipmi_boot'
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
        get 'auto_complete_search'
        get 'template_used'
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
    end
  end

  resources :hostgroups, :as => :old_hostgroups, :except => [:show] do
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

  resources :puppetclasses, :only => [] do
    constraints(:id => /[^\/]+/) do
      resources :hosts, :as => :old_hosts
    end
  end

  if SETTINGS[:locations_enabled]
    resources :locations, :only => [] do
      resources :hosts, :as => :old_hosts, :only => :index
      member do
        get 'assign_hosts', :as => "old_assign_hosts"
        post 'assign_all_hosts', :as => "old_assign_all_hosts"
        put 'assign_selected_hosts', :as => "old_assign_selected_hosts"
      end
    end
  end

  if SETTINGS[:organizations_enabled]
    resources :organizations, :only => [] do
      member do
        get 'assign_hosts', :as => "old_assign_hosts"
        post 'assign_all_hosts', :as => "old_assign_all_hosts"
        put 'assign_selected_hosts', :as => "old_assign_selected_hosts"
      end
    end
  end

end
