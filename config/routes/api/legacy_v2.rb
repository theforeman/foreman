# config/routes/api/v2.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do

    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiConstraints.new(:version => 2) do

      resources :hostgroups, :as => :old_hostgroups, :except => [:new, :edit] do
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

      resources :puppetclasses, :except => [:new, :edit] do
        resources :hostgroups, :as => :old_hostgroups, :only => [:index]
      end

      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :hosts, :as => :old_hosts, :except => [:new, :edit] do
          get :status, :on => :member
          get :puppetrun, :on => :member
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
          resources :hostgroups, :as => :old_hostgroups, :only => [:index, :show]

          resources :organizations, :except => [:new, :edit] do
            resources :hostgroups, :as => :old_hostgroups, :only => [:index, :show]
          end
        end
      end

      if SETTINGS[:organizations_enabled]
        resources :organizations, :except => [:new, :edit] do
          resources :hostgroups, :as => :old_hostgroups, :only => [:index, :show]

          resources :locations, :except => [:new, :edit] do
            resources :hostgroups, :as => :old_hostgroups, :only => [:index, :show]
          end

        end
      end

     end
  end
end
