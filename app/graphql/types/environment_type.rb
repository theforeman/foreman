Types::EnvironmentType = GraphQL::ObjectType.define do
  name 'Environment'
  description 'An Environment'

  backed_by_model :environment do
    attr :id
    attr :name
  end

  connection :puppetclasses, Types::PuppetclassType.connection_type do
    resolve(proc { |obj| AssociationLoader.for(obj.class, :puppetclasses).load(obj) })
  end
end
