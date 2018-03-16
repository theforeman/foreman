Types::JsonType = GraphQL::ScalarType.define do
  name 'JSON'

  coerce_input ->(value, _ctx) { value }
  coerce_result ->(value, _ctx) { value }
end
