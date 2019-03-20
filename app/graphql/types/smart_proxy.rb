module Types
  class SmartProxy < BaseObject
    description 'A SmartProxy'

    global_id_field :id
    timestamps
    field :name, String
    field :url, String

    has_many :hosts, Types::Host
  end
end
