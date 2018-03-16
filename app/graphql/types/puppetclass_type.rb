Types::PuppetclassType = GraphQL::ObjectType.define do
  name 'Puppetclass'
  description 'A Puppetclass'

  backed_by_model :puppetclass do
    attr :id
    attr :name
  end
end
