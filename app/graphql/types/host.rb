module Types
  class Host < BaseObject
    description 'A Host'

    global_id_field :id
    timestamps
    field :name, String, null: false

    belongs_to :environment, Types::Environment
    belongs_to :model, Types::Model
    has_many :fact_names, Types::FactName
    has_many :fact_values, Types::FactValue
  end
end
