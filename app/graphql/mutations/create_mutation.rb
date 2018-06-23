module Mutations
  class CreateMutation < BaseMutation
    field :errors, [Types::AttributeError], null: false

    def resolve(params)
      object = initialize_object(params)

      validate_object(object)
      authorize!(object, :create)

      save_object(object)
    end

    private

    def initialize_object(params)
      resource_class.new(params)
    end
  end
end
