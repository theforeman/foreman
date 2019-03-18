module Types
  class Domain < BaseObject
    description 'A Domain'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :fullname, String, null: true

    has_many :subnets, Types::Subnet
  end
end
