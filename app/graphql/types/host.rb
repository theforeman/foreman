module Types
  class Host < BaseObject
    description 'A Host'

    global_id_field :id
    timestamps
    field :name, String

    belongs_to :compute_resource, Types::ComputeResource
    belongs_to :environment, Types::Environment
    belongs_to :model, Types::Model
    has_many :fact_names, Types::FactName
    has_many :fact_values, Types::FactValue
  end
end
