module Types
  class Location < BaseObject
    description 'A Location'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :title, String, null: true
  end
end
