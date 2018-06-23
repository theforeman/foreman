module Types
  class Mutation < BaseObject
    graphql_name 'Mutation'

    field :create_model, mutation: Mutations::Models::Create
    field :update_model, mutation: Mutations::Models::Update
    field :delete_model, mutation: Mutations::Models::Delete
  end
end
