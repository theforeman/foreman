module Types
  class Source < BaseObject
    description 'A Source'

    global_id_field :id
    field :value, String
    field :digest, String
    has_many :logs, Types::Log
  end
end
