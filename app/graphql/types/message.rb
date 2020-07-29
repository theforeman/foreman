module Types
  class Message < BaseObject
    description 'A Message'

    global_id_field :id
    field :value, String
    field :digest, String
    has_many :logs, Types::Log
  end
end
