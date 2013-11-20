# config/routes/api/v1.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do

      # add "constraint" that unconstrained and allows :id to have dot notation ex. sat.redhat.com
      constraints(:id => /[^\/]+/) do
        resources :systems, :path => :hosts, :as => :old_hosts, :except => [:new, :edit] do
          resources :reports       ,:only => [:index, :show] do
            get :last, :on => :collection
          end
          resources :audits        ,:only => :index
          resources :facts         ,:only => :index, :controller => :fact_values
          resources :puppetclasses ,:only => :index
          get :status, :on => :member
        end
      end
      resources :system_groups, :path => :hostgroups, :as => :old_hostgroups, :except => [:new, :edit]
    end

  end

end
