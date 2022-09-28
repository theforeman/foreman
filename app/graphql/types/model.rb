module Types
  class Model < BaseObject
    description 'A Model'

    global_id_field :id
    timestamps
    field :name, String
    field :info, String
    field :vendorClass, String, method: :vendor_class
    field :hardwareModel, String, method: :hardware_model

    has_many :hosts, Types::Host
  end
end
