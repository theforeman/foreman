module Types
  class ComputeProfile < BaseObject
    description 'A Compute Profile'

    global_id_field :id
    timestamps
    field :name, String

    has_many :compute_resources, Types::ComputeResource
  end
end
