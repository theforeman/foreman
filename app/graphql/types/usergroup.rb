module Types
  class Usergroup < BaseObject
    description 'A Usergroup'

    global_id_field :id
    timestamps
    field :name, String
    field :admin, Boolean
  end
end
