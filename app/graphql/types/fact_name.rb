module Types
  class FactName < BaseObject
    description 'A FactName'

    global_id_field :id
    timestamps
    field :name, String
    field :short_name, String
    field :type, String

    has_many :fact_values, Types::FactValue
    has_many :hosts, Types::Host
  end
end
