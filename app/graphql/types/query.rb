module Types
  class Query < BaseObject
    graphql_name 'Query'

    class << self
      def record_field(name, type)
        field name, type, resolver: Resolvers::Generic.for(type).record
      end

      def collection_field(name, type)
        field name, type.connection_type, resolver: Resolvers::Generic.for(type).collection
      end
    end

    include ::Foreman::Plugin::GraphqlPluginFields
    realize_plugin_query_extensions

    field :node, field: GraphQL::Relay::Node.field
    field :nodes, field: GraphQL::Relay::Node.plural_field

    field :currentUser, Types::User, null: true, resolver: Resolvers::User::Current

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

    record_field :personal_access_token, Types::PersonalAccessToken
    collection_field :personal_access_tokens, Types::PersonalAccessToken

    record_field :ptable, Types::Ptable
    collection_field :ptables, Types::Ptable

    record_field :ssh_key, Types::SshKey
    collection_field :ssh_keys, Types::SshKey

    record_field :host, Types::Host
    collection_field :hosts, Types::Host

    record_field :hostgroup, Types::Hostgroup
    collection_field :hostgroups, Types::Hostgroup

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

    record_field :compute_resource, Types::ComputeResource
    collection_field :compute_resources, Types::ComputeResource

    record_field :compute_attribute, Types::ComputeAttribute
    collection_field :compute_attributes, Types::ComputeAttribute

    record_field :medium, Types::Medium
    collection_field :media, Types::Medium

    record_field :bookmark, Types::Bookmark
    collection_field :bookmarks, Types::Bookmark

    field :setting, Types::Setting, resolver: Resolvers::SettingResolver
    field :settings, Types::Setting.connection_type, resolver: Resolvers::SettingsResolver

    record_field :configReport, Types::ConfigReport
    collection_field :configReports, Types::ConfigReport

    record_field :lookup_value, Types::LookupValue
    collection_field :lookup_values, Types::LookupValue

    record_field :permission, Types::Permission
    collection_field :permissions, Types::Permission
  end
end
