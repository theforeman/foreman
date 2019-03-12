module Types
  class Usergroup < BaseObject
    description 'A Usergroup'

    global_id_field :id
    timestamps
    field :name, String, null: false
    field :admin, Boolean, null: false
  end
end
