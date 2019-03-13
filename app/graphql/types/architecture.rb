module Types
  class Architecture < BaseObject
    description 'An Architecture'

    global_id_field :id
    timestamps
    field :name, String, null: true
  end
end
