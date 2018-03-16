Types::OperatingsystemType = GraphQL::ObjectType.define do
  name 'Operatingsystem'
  description 'An Operatingsystem'

  backed_by_model :operatingsystem do
    attr :id
    attr :name
    attr :title
    attr :type
  end
end
