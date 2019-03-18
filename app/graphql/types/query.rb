module Types
  class Query < GraphQL::Schema::Object
    graphql_name 'Query'

    class << self
      def record_field(name, model)
        field name, "Types::#{model}".safe_constantize,
          resolver: Resolvers::Generic.for(model).record
      end

      def collection_field(name, model)
        field name, "Types::#{model}".safe_constantize.connection_type,
          resolver: Resolvers::Generic.for(model).collection
      end
    end

    field :node, field: GraphQL::Relay::Node.field
    field :nodes, field: GraphQL::Relay::Node.plural_field

    record_field :model, ::Model
    collection_field :models, ::Model

    record_field :location, ::Location
    collection_field :locations, ::Location

    record_field :operatingsystem, ::Operatingsystem
    collection_field :operatingsystems, ::Operatingsystem

    record_field :subnet, ::Subnet
    collection_field :subnets, ::Subnet

    record_field :usergroup, ::Usergroup
    collection_field :usergroups, ::Usergroup

    record_field :host, ::Host
    collection_field :hosts, ::Host

    record_field :architecture, ::Architecture
    collection_field :architectures, ::Architecture

    record_field :smart_proxy, ::SmartProxy
    collection_field :smart_proxies, ::SmartProxy

    record_field :domain, ::Domain
    collection_field :domains, ::Domain
  end
end
