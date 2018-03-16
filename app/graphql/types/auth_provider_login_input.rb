Types::AuthProviderLoginInput = GraphQL::InputObjectType.define do
  name 'AUTH_PROVIDER_LOGIN'

  argument :username, !types.String
  argument :password, !types.String
end
