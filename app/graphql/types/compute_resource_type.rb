Types::ComputeResourceType = GraphQL::ObjectType.define do
  name 'ComputeResource'
  description 'A ComputeResource'

  backed_by_model :compute_resource do
    attr :id
    attr :name
  end

  field :computeAttributes, types[Types::ComputeAttributeType], resolve: (proc do |obj|
    AssociationLoader.for(ComputeResource, :compute_attributes).load(obj)
  end)
end
