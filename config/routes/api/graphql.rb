Foreman::Application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    post '/graphql', to: 'graphql#execute'
  end
end
