# config/routes/api/v1.rb
Foreman::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      resources :bookmarks, :except => [:new, :edit]
      resources :architectures, :except => [:new, :edit]
      resources :users, :except => [:new, :edit]
      resources :dashboard, :only => [:index]
      resources :media, :except => [:new, :edit]
      resources :environments, :except => [:new, :edit]
      resources :operatingsystems, :except => [:new, :edit] do
        member do
          get 'bootfiles'
        end
      end
      resources :config_templates, :except => [:new, :edit] do
        collection do
          get 'build_pxe_default'
          get 'revision'
        end
      end
      constraints(:id => /[^\/]+/) do
        resources :domains, :except => [:new, :edit]
      end
      resources :subnets, :except => [:new, :edit] do
        post 'freeip', :on => :collection
      end
      resources :auth_source_ldaps, :except => [:new, :edit]
      resources :compute_resources, :except => [:new, :edit]

      match '/', :to => 'home#index'
      match 'status', :to => 'home#status', :as => "status"
      match '*other', :to => 'home#route_error'
    end

  end

end
