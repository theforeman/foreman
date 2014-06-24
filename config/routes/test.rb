if Rails.env.test?
  Foreman::Application.routes.draw do
    resources :testable, :only => :index

    namespace :api do
      resources :testable, :only => :index do
        get :raise_error, :on => :collection
      end
    end
  end
end
