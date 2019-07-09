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

      bruteforce_protection = Foreman::BruteforceProtection.new(
        request_ip: context[:request_ip]
      )

      if bruteforce_protection.bruteforce_attempt?
        bruteforce_protection.log_bruteforce
        raise GraphQL::ExecutionError, _('Too many tries, please try again in a few minutes.')
      end

      user = User.try_to_login(username, password)

      unless user
        Rails.logger.warn("Failed login attempt from #{context['request_ip']} with username '#{username}'.")
        bruteforce_protection.count_login_failure
        return
      end

      {
        token: user.jwt_token!,
        user: user,
      }
    end
  end
end
