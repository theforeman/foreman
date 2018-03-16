class Mutations::SignInUser < GraphQL::Function
  argument :login, Types::AuthProviderLoginInput

  type do
    name 'SIGN_IN_USER_PAYLOAD'

    field :user_id, types.ID
    field :token, types.String
  end

  def call(obj, args, ctx)
    login = args[:login] || {}
    username = login[:username]
    password = login[:password]
    return unless username && password

    user = User.try_to_login(username, password)
    return unless user

    OpenStruct.new(user_id: user.id, token: user.jwt_token!)
  end
end
