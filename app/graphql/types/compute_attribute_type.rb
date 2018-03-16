Types::ComputeAttributeType = GraphQL::ObjectType.define do
  name 'ComputeAttribute'
  description 'A ComputeAttribute'

  backed_by_model :compute_attribute do
    attr :id
    attr :name
  end

  field :vmAttrs, Types::VmAttrsType, resolve: (proc do |obj|
    obj.vm_attrs.map do |k, v|
      [k.to_s, v.is_a?(Hash) ? v : v.to_s]
    end.to_h
  end)
end
