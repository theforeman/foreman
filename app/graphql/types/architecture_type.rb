Types::ArchitectureType = GraphQL::ObjectType.define do
  name 'Architecture'
  description 'An Architecture'

  backed_by_model :architecture do
    attr :id
    attr :name
  end
end
