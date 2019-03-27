module Types
  class Puppetclass < BaseObject
    description 'A Puppetclass'

    global_id_field :id
    timestamps
    field :name, String

    has_many :environments, Types::Environment
    has_many :locations, Types::Location
    has_many :organizations, Types::Organization
  end
end
