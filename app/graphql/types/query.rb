module Types
  class Query < GraphQL::Schema::Object
    graphql_name 'Query'

    class << self
      def record_field(name, type)
        field name, type, resolver: Resolvers::Generic.for(type).record
      end

      def collection_field(name, type)
        field name, type.connection_type, resolver: Resolvers::Generic.for(type).collection
      end
    end

    field :node, field: GraphQL::Relay::Node.field
    field :nodes, field: GraphQL::Relay::Node.plural_field

    record_field :model, Types::Model
    collection_field :models, Types::Model

    record_field :location, Types::Location
    collection_field :locations, Types::Location

    record_field :organization, Types::Organization
    collection_field :organizations, Types::Organization

    record_field :operatingsystem, Types::Operatingsystem
    collection_field :operatingsystems, Types::Operatingsystem

    record_field :subnet, Types::Subnet
    collection_field :subnets, Types::Subnet

    record_field :user, Types::User
    collection_field :users, Types::User

    record_field :usergroup, Types::Usergroup
    collection_field :usergroups, Types::Usergroup

    record_field :host, Types::Host
    collection_field :hosts, Types::Host

    record_field :architecture, Types::Architecture
    collection_field :architectures, Types::Architecture

    record_field :domain, Types::Domain
    collection_field :domains, Types::Domain

    record_field :smart_proxy, Types::SmartProxy
    collection_field :smart_proxies, Types::SmartProxy

    record_field :fact_name, Types::FactName
    collection_field :fact_names, Types::FactName

    record_field :fact_value, Types::FactValue
    collection_field :fact_values, Types::FactValue
  end
end
