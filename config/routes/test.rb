if Rails.env.test?
  Foreman::Application.routes.draw do
    namespace :api do
      resources :testable, :only => :index
    end
  end
end
