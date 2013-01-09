# config/routes/api/v2.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 2) do

      resources :audits, :only => [:index, :show]
      resources :auth_source_ldaps, :except => [:new, :edit]
      resources :bookmarks, :except => [:new, :edit]
      resources :common_parameters, :except => [:new, :edit]
      # add "contraint" that uncontrains and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :domains, :except => [:new, :edit]
        resources :hosts, :except => [:new, :edit]
        resources :compute_resources, :except => [:new, :edit] do
          resources :images, :except => [:new, :edit]
        end
      end

      resources :dashboard, :only => [:index]
      resources :environments, :except => [:new, :edit]
      resources :fact_values, :except => [:new, :edit]
      resources :lookup_keys, :except => [:new, :edit]
      resources :media, :except => [:new, :edit]
      resources :models, :except => [:new, :edit]
      resources :operatingsystems, :except => [:new, :edit] do
        member do
          get 'bootfiles'
        end
      end
      resources :ptables, :except => [:new, :edit]
      resources :puppetclasses, :except => [:new, :edit]
      resources :roles, :except => [:new, :edit]
      resources :reports, :only => [:index, :show, :destroy]
      resources :settings, :only => [:index, :show, :update]
      resources :smart_proxies, :except => [:new, :edit]
      resources :subnets, :except => [:new, :edit]
      resources :usergroups, :except => [:new, :edit]
      resources :users, :except => [:new, :edit]
      resources :template_kinds, :only => [:index]
    end

    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiConstraints.new(:version => 2) do
      resources :architectures, :only => [:index, :show]
      resources :hostgroups, :except => [:new, :edit]

      # only nested routes parameters points to v2.  RESTful routes for domains, hosts, hostgroups, operating systems point to v1 above
      constraints(:id => /[^\/]+/) do
        resources :domains, :except => [:new, :edit] do
            resources :parameters, :on => :member
        end
        resources :hosts, :except => [:new, :edit] do
            resources :parameters, :on => :member
        end
      end
      resources :hostgroups, :except => [:new, :edit] do
        resources :parameters, :on => :member
      end
      resources :operatingsystems, :except => [:new, :edit] do
          resources :parameters, :on => :member
      end
      resources :config_templates, :except => [:new, :edit] do
        collection do
          get 'build_pxe_default'
          get 'revision'
        end
        resources :template_combinations, :only => [:index, :create]
      end
      resources :template_combinations, :only => [:show, :destroy]

      match '/', :to => 'home#index'
      match 'status', :to => 'home#status', :as => "status"
      match '*other', :to => 'home#route_error'

    end

  end

end
