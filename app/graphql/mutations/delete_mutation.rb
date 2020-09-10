module Mutations
  class DeleteMutation < BaseMutation
    argument :id, ID, required: true

    field :id, ID, 'The deleted object ID.', null: false
    field :errors, [Types::AttributeError], null: false

    def resolve(id:)
      object = load_object_by(id: id)
      authorize!(object, :destroy)

      User.as(context[:current_user]) do
        errors = if object.destroy
                   []
                 else
                   map_errors_to_path(object)
                 end

        {
          id: id,
          errors: errors,
        }
      end
    end
  end
end
