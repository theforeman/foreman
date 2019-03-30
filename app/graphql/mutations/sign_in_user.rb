# frozen_string_literal: true

module Mutations
  class SignInUser < BaseMutation
    null true

    argument :username, String, required: true
    argument :password, String, required: true

    field :token, String, null: false
    field :user, Types::User, null: false

    def resolve(username:, password:)
      return unless username && password

      user = User.try_to_login(username, password)
      return unless user

      {
        token: user.jwt_token!,
        user: user
      }
    end
  end
end
