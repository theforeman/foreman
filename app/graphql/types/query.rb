Types::Query = GraphQL::ObjectType.define do
  name 'Query'

  field :currentUser, function: Queries::CurrentUser.new

  field :model, Types::ModelType,
        function: Queries::FetchField.new(type: Types::ModelType, model_class: Model)
  field :bookmark, Types::BookmarkType,
        function: Queries::FetchField.new(type: Types::BookmarkType, model_class: Bookmark)
  field :subnet, Types::SubnetType,
        function: Queries::FetchField.new(type: Types::SubnetType, model_class: Subnet)
  field :host, Types::HostType,
        function: Queries::FetchField.new(type: Types::HostType, model_class: Host::Managed)
  field :smartProxy, Types::SmartProxyType,
        function: Queries::FetchField.new(type: Types::SmartProxyType, model_class: SmartProxy)
  field :environment, Types::EnvironmentType,
        function: Queries::FetchField.new(type: Types::EnvironmentType, model_class: Environment)
  field :puppetclass, Types::PuppetclassType,
        function: Queries::FetchField.new(type: Types::PuppetclassType, model_class: Puppetclass)
  field :domain, Types::DomainType,
        function: Queries::FetchField.new(type: Types::DomainType, model_class: Domain)

  connection :models, Types::ModelType.connection_type,
             function: Queries::PluralField.new(type: Types::ModelType, model_class: Model)
  connection :bookmarks, Types::BookmarkType.connection_type,
             function: Queries::PluralField.new(type: Types::BookmarkType, model_class: Bookmark)
  connection :subnets, Types::SubnetType.connection_type,
             function: Queries::PluralField.new(type: Types::SubnetType, model_class: Subnet)
  connection :hosts, Types::HostType.connection_type,
             function: Queries::PluralField.new(type: Types::HostType, model_class: Host::Managed)
  connection :smartProxies, Types::SmartProxyType.connection_type,
             function: Queries::PluralField.new(type: Types::SmartProxyType, model_class: SmartProxy)
  connection :environments, Types::EnvironmentType.connection_type,
             function: Queries::PluralField.new(type: Types::EnvironmentType, model_class: Environment)
  connection :puppetclasses, Types::PuppetclassType.connection_type,
             function: Queries::PluralField.new(type: Types::PuppetclassType, model_class: Puppetclass)
  connection :domains, Types::DomainType.connection_type,
             function: Queries::PluralField.new(type: Types::DomainType, model_class: Domain)
end
