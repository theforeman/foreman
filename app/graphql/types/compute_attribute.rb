module Types
  class ComputeAttribute < BaseObject
    description 'A ComputeAttribute'

    global_id_field :id
    timestamps
    field :name, String

    belongs_to :compute_resource, Types::ComputeResource
  end
end
