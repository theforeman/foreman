if Rails.env.test?
  Foreman::Application.routes.draw do
    resources :testable_resources, :only => :index

    namespace :api do
      namespace :v2 do
        resources :testable, :only => [:create, :index, :new]
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
