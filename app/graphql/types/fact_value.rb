module Types
  class FactValue < BaseObject
    description 'A FactValue'

    global_id_field :id
    timestamps
    field :value, String

    belongs_to :fact_name, Types::FactName
    belongs_to :host, Types::Host
  end
end
