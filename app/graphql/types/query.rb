module Types
  class Query < GraphQL::Schema::Object
    graphql_name 'Query'

    field :node, field: GraphQL::Relay::Node.field
    field :nodes, field: GraphQL::Relay::Node.plural_field

    field :model, Types::Model, resolver: Resolvers::Model
    field :models, Types::Model.connection_type, resolver: Resolvers::Models

    field :location, Types::Location, resolver: Resolvers::Location
    field :locations, Types::Location.connection_type, resolver: Resolvers::Locations
  end
end
