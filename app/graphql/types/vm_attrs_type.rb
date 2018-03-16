Types::VmAttrsType = GraphQL::ObjectType.define do
  name 'VmAttr'
  description 'A VmAttr'

  field :cpus, types.String, hash_key: 'cpus'
  field :memory, types.String, hash_key: 'memory'
  field :volumesAttributes, Types::JsonType, resolve: (proc do |obj|
    obj['volumes_attributes']
  end)
end
