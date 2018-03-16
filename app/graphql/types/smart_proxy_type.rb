Types::SmartProxyType = GraphQL::ObjectType.define do
  name 'SmartProxy'
  description 'A SmartProxy'

  backed_by_model :smart_proxy do
    attr :id
    attr :name
    attr :url
  end
end
