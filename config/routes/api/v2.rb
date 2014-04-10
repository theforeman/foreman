# config/routes/api/v2.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do

    # new v2 routes that point to v2
    scope "(:apiv)", :module => :v2, :defaults => {:apiv => 'v2'}, :apiv => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do

      resources :architectures, :except => [:new, :edit]

      resources :audits, :only => [:index, :show]

      resources :auth_source_ldaps, :except => [:new, :edit]

      resources :bookmarks, :except => [:new, :edit]

      resources :common_parameters, :except => [:new, :edit]

      resources :config_templates, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        collection do
          get 'build_pxe_default'
          get 'revision'
        end
        resources :template_combinations, :only => [:index, :create]
      end

      resources :dashboard, :only => [:index]

      resources :environments, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :smart_proxies, :only => [] do
          post :import_puppetclasses, :on => :member
        end
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :puppetclasses, :except => [:new, :edit] do
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
      end

      resources :fact_values, :only => [:index]

      resources :hostgroups, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        resources :parameters, :except => [:new, :edit] do
          collection do
            delete '/', :to => :reset
          end
        end
        resources :smart_variables, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :puppetclasses, :except => [:new, :edit]
        resources :hostgroup_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
      end

      resources :media, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :models, :except => [:new, :edit]

      constraints(:id => /[^\/]+/) do
        resources :operatingsystems, :except => [:new, :edit] do
          get :bootfiles, :on => :member
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end
          resources :os_default_templates, :except => [:new, :edit]
        end
      end

      resources :puppetclasses, :except => [:new, :edit] do
        resources :smart_variables, :except => [:new, :edit] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :smart_class_parameters, :except => [:new, :edit, :create] do
          resources :override_values, :except => [:new, :edit]
        end
        resources :environments, :only => [] do
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
        resources :hostgroups, :only => [:index]
      end

      resources :ptables, :except => [:new, :edit]

      resources :reports, :only => [:index, :show, :destroy] do
        get :last, :on => :collection
      end

      resources :roles, :except => [:new, :edit] do
        resources :filters, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
      end
      resources :permissions, :only => [:index, :show]

      resources :filters, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :settings, :only => [:index, :show, :update]

      resources :smart_variables, :except => [:new, :edit] do
        resources :override_values, :except => [:new, :edit]
      end

      resources :smart_class_parameters, :except => [:new, :edit, :create] do
        resources :override_values, :except => [:new, :edit]
      end

      resources :override_values, :only => [:update, :destroy]

      resources :statistics, :only => [:index]

      match '/', :to => 'home#index'
      match 'status', :to => 'home#status', :as => "status"

      resources :reports, :only => [:create]

      resources :subnets, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :usergroups, :except => [:new, :edit]

      resources :users, :except => [:new, :edit] do
        (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
        (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
      end

      resources :template_kinds, :only => [:index]

      resources :template_combinations, :only => [:show, :destroy]
      resources :config_groups, :except => [:new, :edit]

      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :compute_resources, :except => [:new, :edit] do
          resources :images, :except => [:new, :edit]
          get :available_images, :on => :member
          get :available_clusters, :on => :member
          get :available_networks, :on => :member
          get :available_storage_domains, :on => :member
          get 'available_clusters/(:cluster_id)/available_networks', :to => 'compute_resources#available_networks', :on => :member
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
        resources :realms, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
        end
        resources :domains, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end
        end
        resources :smart_proxies, :except => [:new, :edit] do
          (resources :locations, :only => [:index, :show]) if SETTINGS[:locations_enabled]
          (resources :organizations, :only => [:index, :show]) if SETTINGS[:organizations_enabled]
          put :refresh, :on => :member
          post :import_puppetclasses, :on => :member
          resources :environments, :only => [] do
            post :import_puppetclasses, :on => :member
          end
          resources :autosign, :only => [:index]
        end
        resources :hosts, :except => [:new, :edit] do
          get :status, :on => :member
          put :puppetrun, :on => :member
          put :boot, :on => :member
          put :power, :on => :member
          post :facts, :on => :collection
          resources :audits        ,:only => :index
          resources :facts         ,:only => :index, :controller => :fact_values
          resources :host_classes, :path => :puppetclass_ids, :only => [:index, :create, :destroy]
          resources :interfaces, :except => [:new, :edit]
          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end
          resources :puppetclasses, :except => [:new, :edit]
          resources :reports, :only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :smart_variables, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
          resources :smart_class_parameters, :except => [:new, :edit, :create] do
            resources :override_values, :except => [:new, :edit]
          end
        end
      end

      if SETTINGS[:locations_enabled]
        resources :locations, :except => [:new, :edit] do

          # scoped by location
          resources :domains, :only => [:index, :show]
          resources :realms, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]

          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end

           # scoped by location AND organization
          resources :organizations, :except => [:new, :edit] do
            resources :domains, :only => [:index, :show]
            resources :realms, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
            resources :filters, :only => [:index, :show]
          end

        end
      end

      if SETTINGS[:organizations_enabled]
        resources :organizations, :except => [:new, :edit] do

          # scoped by organization
          resources :domains, :only => [:index, :show]
          resources :realms, :only => [:index, :show]
          resources :subnets, :only => [:index, :show]
          resources :hostgroups, :only => [:index, :show]
          resources :environments, :only => [:index, :show]
          resources :users, :only => [:index, :show]
          resources :config_templates, :only => [:index, :show]
          resources :compute_resources, :only => [:index, :show]
          resources :media, :only => [:index, :show]
          resources :smart_proxies, :only => [:index, :show]
          resources :filters, :only => [:index, :show]

          resources :parameters, :except => [:new, :edit] do
            collection do
              delete '/', :to => :reset
            end
          end

          # scoped by location AND organization
          resources :locations, :except => [:new, :edit] do
            resources :domains, :only => [:index, :show]
            resources :realms, :only => [:index, :show]
            resources :subnets, :only => [:index, :show]
            resources :hostgroups, :only => [:index, :show]
            resources :environments, :only => [:index, :show]
            resources :users, :only => [:index, :show]
            resources :config_templates, :only => [:index, :show]
            resources :compute_resources, :only => [:index, :show]
            resources :media, :only => [:index, :show]
            resources :smart_proxies, :only => [:index, :show]
            resources :filters, :only => [:index, :show]
          end

        end
      end
      get 'orchestration/(:id)/tasks', :to => 'tasks#index'
      resources :plugins, :only => [:index]
    end
  end
end
