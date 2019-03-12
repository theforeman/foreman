module Types
  class Model < BaseObject
    description 'A Model'

    global_id_field :id
    timestamps
    field :name, String, null: false
    field :info, String, null: true
    field :vendorClass, String, null: true
    field :hardwareModel, String, null: true
  end
end
