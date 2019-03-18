module Types
  class Domain < BaseObject
    description 'A Domain'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :fullname, String, null: true

    field :subnets, Types::Subnet.connection_type, null: true,
      resolve: proc { |object| CollectionLoader.for(object.class, :subnets).load(object) }
  end
end
