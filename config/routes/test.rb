if Rails.env.test?
  Foreman::Application.routes.draw do
    resources :testable, :only => :index
    resources :testable_strong_params, :only => :create
    resources :my_hosts, :only => :create
    resources :testable_no_params, :only => :create

    namespace :api do
      namespace :v2 do
        resources :testable, :only => [:create, :index]
      end

      resources :testable, :only => :index do
        get :raise_error, :on => :collection
        get :required_nested_values, :on => :collection
        get :optional_nested_values, :on => :collection
        get :nested_values, :on => :collection
      end
    end
  end
end
