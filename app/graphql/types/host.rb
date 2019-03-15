module Types
  class Host < BaseObject
    description 'A Host'

    global_id_field :id
    timestamps
    field :name, String, null: false
    field :model, Types::Model, null: true,
      resolve: proc { |object| RecordLoader.for(::Model).load(object.model_id) }
  end
end
