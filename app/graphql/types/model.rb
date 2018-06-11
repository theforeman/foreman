module Types
  class Model < BaseObject
    description 'A Model'

    implements GraphQL::Relay::Node.interface

    global_id_field :id

    field :name, String, null: false
    field :info, String, null: true
    field :vendorClass, String, null: true
    field :hardwareModel, String, null: true
  end
end
