module Mutations
  class UpdateMutation < BaseMutation
    field :errors, [Types::AttributeError], null: false

    def resolve(params)
      object = load_object_by(id: params[:id])
      authorize!(object, :edit)

      object.assign_attributes(params.except(:id))

      save_object(object)
    end
  end
end
