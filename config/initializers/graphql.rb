require 'rack'
require 'rack/cors'
require 'graphql'
require 'graphql/batch'
require 'graphql/activerecord'

Foreman::Application.configure do |app|
  initializer 'configure_cors', :before=> :build_middleware_stack do |app|
    app.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV['FOREMAN_GRAPHQL_CORS_DOMAINS'].to_s.split(',')
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end

  if Rails.env.development?
    GraphiQL::Rails::EditorsController.send(:include, GraphiqlExt::JwtAuth)
  end

  GraphQL::Models::DatabaseTypes.register(:text, 'GraphQL::STRING_TYPE')
  GraphQL::Models::DatabaseTypes.register(:datetime, 'Types::DateTimeType')

  # The `graphql/activerecord` gem assumes that if your model is called `MyModel`,
  # the corresponding type is `MyModelType`.
  # This line supports our types structure: `Types::MyModelType`
  GraphQL::Models.model_to_graphql_type = (lambda do |model_class|
    "Types::#{model_class.name}Type".safe_constantize
  end)
end
