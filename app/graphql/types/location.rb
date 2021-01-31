module Types
  class Location < BaseObject
    description 'A Location'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String

    has_many :environments, Types::Environment
    has_many :hosts, Types::Host
  end
end
