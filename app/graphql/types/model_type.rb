Types::ModelType = GraphQL::ObjectType.define do
  name 'Model'
  description 'A Model'

  backed_by_model :model do
    attr :id
    attr :name
    attr :info
    attr :vendor_class
    attr :hardware_model
  end
end
