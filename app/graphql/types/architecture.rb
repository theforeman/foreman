module Types
  class Architecture < BaseObject
    description 'An Architecture'

    global_id_field :id
    timestamps
    field :name, String

    has_many :hosts, Types::Host
  end
end
