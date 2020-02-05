module Mutations
  module Models
    class Update < UpdateMutation
      graphql_name 'UpdateModelMutation'
      description 'Updates existing hardware model.'

      argument :name, String
      argument :info, String
      argument :vendor_class, String
      argument :hardware_model, String

      field :model, Types::Model, 'The hardware model.', null: true
    end
  end
end
