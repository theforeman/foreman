module Types
  class FactName < BaseObject
    description 'A FactName'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :short_name, String, null: true
    field :type, String, null: true

    has_many :fact_values, Types::FactValue
  end
end
