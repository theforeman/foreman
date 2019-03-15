module Types
  class SmartProxy < BaseObject
    description 'A SmartProxy'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :url, String, null: true
  end
end
