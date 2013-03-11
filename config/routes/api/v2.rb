# config/routes/api/v2.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 2) do

      resources :architectures, :except => [:new, :edit]
      resources :audits, :only => [:index, :show]
      resources :auth_source_ldaps, :except => [:new, :edit]
      resources :bookmarks, :except => [:new, :edit]
      resources :common_parameters, :except => [:new, :edit]
      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :domains, :except => [:new, :edit]
        resources :hosts, :except => [:new, :edit] do
          resources :reports       ,:only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :audits        ,:only => :index
          resources :facts         ,:only => :index, :controller => :fact_values
          resources :puppetclasses ,:only => :index
          get :status, :on => :member
        end
        resources :compute_resources, :except => [:new, :edit] do
          resources :images, :except => [:new, :edit]
        end
      end
      resources :dashboard, :only => [:index]
      resources :environments, :except => [:new, :edit]
      resources :fact_values, :except => [:new, :edit]
      resources :hostgroups, :except => [:new, :edit]
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
      resources :reports, :only => [:index, :show, :destroy] do
        get :last, :on => :collection
      end
      resources :settings, :only => [:index, :show, :update]
      resources :smart_proxies, :except => [:new, :edit]
      resources :subnets, :except => [:new, :edit]
      resources :usergroups, :except => [:new, :edit]
      resources :users, :except => [:new, :edit]
      resources :template_kinds, :only => [:index]

      match '/', :to => 'home#index'
      match 'status', :to => 'home#status', :as => "status"
    end

    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiConstraints.new(:version => 2) do

      resources :config_templates, :except => [:new, :edit] do
        collection do
          get 'build_pxe_default'
          get 'revision'
        end
        resources :template_combinations, :only => [:index, :create]
      end
      resources :template_combinations, :only => [:show, :destroy]

      constraints(:id => /[^\/]+/) do
        resources :hosts, :only => [] do
          resources :parameters, :except => [:new, :edit] do
            collection do 
              delete '/', :to => :reset
            end
          end
        end

        resources :domains, :only => [] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :parameters, :except => [:new, :edit] do
            collection do 
              delete '/', :to => :reset 
            end
          end 
        end

        resources :compute_resources, :only => [] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
      end

      resources :subnets, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :environments, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :hostgroups, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :parameters, :except => [:new, :edit] do
          collection do 
            delete '/', :to => :reset 
          end
        end 
      end

      resources :smart_proxies, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :users, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :media, :only => [] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :operatingsystems, :only => [] do
        resources :parameters, :except => [:new, :edit] do
          collection do 
            delete '/', :to => :reset 
          end
        end 
      end

      if SETTINGS[:locations_enabled]
        resources :locations do

          # scoped by location
          resources :domains, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]

          # scoped by location AND organization
          resources :organizations do
            resources :domains, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
          end

        end
      end

      if SETTINGS[:organizations_enabled]
        resources :organizations do

          # scoped by organization
          resources :domains, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]

          # scoped by location AND organization
          resources :locations do
            resources :domains, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
          end

        end
      end
    end

    match '*other', :to => 'v1/home#route_error', :constraints => ApiConstraints.new(:version => 2)
  end

end
