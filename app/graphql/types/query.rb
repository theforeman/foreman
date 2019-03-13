module Types
  class Query < GraphQL::Schema::Object
    graphql_name 'Query'

    field :node, field: GraphQL::Relay::Node.field
    field :nodes, field: GraphQL::Relay::Node.plural_field

    field :model, Types::Model, resolver: Resolvers::Model
    field :models, Types::Model.connection_type, resolver: Resolvers::Models

    field :location, Types::Location, resolver: Resolvers::Location
    field :locations, Types::Location.connection_type, resolver: Resolvers::Locations

    field :operatingsystem, Types::Operatingsystem, resolver: Resolvers::Operatingsystem
    field :operatingsystems, Types::Operatingsystem.connection_type, resolver: Resolvers::Operatingsystems

    field :subnet, Types::Subnet, resolver: Resolvers::Subnet
    field :subnets, Types::Subnet.connection_type, resolver: Resolvers::Subnets

    field :usergroup, Types::Usergroup, resolver: Resolvers::Usergroup
    field :usergroups, Types::Usergroup.connection_type, resolver: Resolvers::Usergroups

    field :architecture, Types::Architecture, resolver: Resolvers::Architecture
    field :architectures, Types::Architecture.connection_type, resolver: Resolvers::Architectures
  end
end
