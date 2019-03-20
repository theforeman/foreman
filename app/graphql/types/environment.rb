module Types
  class Environment < BaseObject
    description 'An Environment'

    global_id_field :id
    timestamps
    field :name, String, null: true
  end
end
