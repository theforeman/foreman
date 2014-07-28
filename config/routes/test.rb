if Rails.env.test?
  Foreman::Application.routes.draw do
    resources :testable, :only => :index

    namespace :api do
      namespace :v2 do
        resources :testable, :only => [:create, :index]
      end

      resources :testable, :only => :index do
        get :raise_error, :on => :collection
      end
    end
  end
end
