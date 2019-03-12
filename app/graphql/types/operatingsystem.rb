module Types
  class Operatingsystem < BaseObject
    description 'An Operatingsystem'

    global_id_field :id
    timestamps
    field :name, String, null: true
    field :title, String, null: true
    field :type, String, null: true
    field :fullname, String, null: true
  end
end
