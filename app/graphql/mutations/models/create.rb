module Mutations
  module Models
    class Create < CreateMutation
      graphql_name 'CreateModelMutation'
      description 'Creates a new hardware model.'

      argument :name, String
      argument :info, String
      argument :vendor_class, String
      argument :hardware_model, String

      field :model, Types::Model, 'The new hardware model.', null: true
    end
  end
end
