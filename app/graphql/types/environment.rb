module Types
  class Environment < BaseObject
    description 'An Environment'

    global_id_field :id
    timestamps
    field :name, String

    has_many :locations, Types::Location
    has_many :organizations, Types::Organization
  end
end
