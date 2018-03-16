Types::Mutation = GraphQL::ObjectType.define do
  name 'Mutation'

  field :signInUser, function: Mutations::SignInUser.new
end
