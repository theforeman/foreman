module Types
  class Model < BaseObject
    description 'A Model'

    global_id_field :id
    timestamps
    field :name, String
    field :info, String
    field :vendorClass, String
    field :hardwareModel, String

    has_many :hosts, Types::Host
  end
end
