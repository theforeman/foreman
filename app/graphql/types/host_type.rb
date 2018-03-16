Types::HostType = GraphQL::ObjectType.define do
  name 'Host'
  description 'A Host'

  backed_by_model :host do
    attr :id
    attr :name
    attr :build
    attr :created_at
  end

  field :location, Types::LocationType, resolve: (proc do |obj|
    RecordLoader.for(Location).load(obj.location_id)
  end)

  field :operatingsystem, Types::OperatingsystemType, resolve: (proc do |obj|
    RecordLoader.for(Operatingsystem).load(obj.operatingsystem_id)
  end)

  field :architecture, Types::ArchitectureType, resolve: (proc do |obj|
    RecordLoader.for(Architecture).load(obj.architecture_id)
  end)

  field :computeResource, Types::ComputeResourceType, resolve: (proc do |obj|
    RecordLoader.for(ComputeResource).load(obj.compute_resource_id)
  end)

  field :environment, Types::EnvironmentType, resolve: (proc do |obj|
    RecordLoader.for(Environment).load(obj.environment_id)
  end)

  field :puppetProxy, Types::SmartProxyType, resolve: (proc do |obj|
    RecordLoader.for(SmartProxy).load(obj.puppet_proxy_id)
  end)

  field :puppetCaProxy, Types::SmartProxyType, resolve: (proc do |obj|
    RecordLoader.for(SmartProxy).load(obj.puppet_ca_proxy_id)
  end)

  field :puppetclasses, types[Types::PuppetclassType], resolve: (proc do |obj|
    AssociationLoader.for(obj.class, :puppetclasses).load(obj)
  end)
end
