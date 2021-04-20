module Types
  class Organization < BaseObject
    description 'An Organization'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String
  end
end
