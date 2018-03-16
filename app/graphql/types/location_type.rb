Types::LocationType = GraphQL::ObjectType.define do
  name 'Location'
  description 'A Location'

  backed_by_model :location do
    attr :id
    attr :name
    attr :title
  end
end
