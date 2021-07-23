module Types
  class Permission < BaseObject
    description 'A Permission'

    global_id_field :id
    timestamps
    field :name, String
    field :resource_type, String
  end
end
