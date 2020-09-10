module Mutations
  class UpdateMutation < BaseMutation
    field :errors, [Types::AttributeError], null: false

    argument :id, ID, required: true

    def resolve(params)
      object = load_object_by(id: params[:id])
      authorize!(object, :edit)

      assign_attributes object, params.except(:id)

      save_object(object)
    end

    def assign_attributes(object, attributes)
      object.assign_attributes(attributes)
    end
  end
end
