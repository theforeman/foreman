module Types
  class Model < BaseObject
    description 'A Model'

    global_id_field :id
    timestamps
    field :name, String, null: false
    field :info, String, null: true
    field :vendorClass, String, null: true
    field :hardwareModel, String, null: true

    field :hosts, Types::Host.connection_type, null: false,
      resolve: proc { |object| CollectionLoader.for(object.class, :hosts).load(object) }
  end
end
