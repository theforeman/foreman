require 'graphql'
require 'graphql/batch'

Rails.application.config.assets.precompile += %w(graphiql/rails/application.js graphiql/rails/application.css) if Rails.env.development?
