require 'test_helper'

module Mutations
  class SignInUserMutationTest < ActiveSupport::TestCase
    setup do
      Rails.cache.clear
    end

    teardown do
      Rails.cache.clear
    end

    let(:context) { { request_ip: '127.0.0.1' } }
    let(:user) { FactoryBot.create(:user, firstname: 'Jane', lastname: 'Doe') }
    let(:global_id) { Foreman::GlobalId.for(user) }
    let(:variables) do
      {
        username: user.login,
        password: 'password',
      }
    end
    let(:query) do
      <<-GRAPHQL
          mutation SignInUserMutation (
              $username: String!,
              $password: String!,
            ) {
            signInUser(input: {
              username: $username,
              password: $password,
            }) {
              token
              user {
                id,
                fullname,
                login
              }
            }
          }
      GRAPHQL
    end

    test 'signs a user in' do
      result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
      assert_empty result['errors']

      data = result['data']['signInUser']

      assert_equal user.id, JwtToken.new(data['token']).decode['user_id']
      assert_equal global_id, data['user']['id']
      assert_equal user.fullname, data['user']['fullname']
      assert_equal user.login, data['user']['login']
    end

    test 'does not sign a user in when the credentials are wrong' do
      variables[:password] = 'wrong-password'

      result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
      assert_empty result['errors']

      assert_nil result['data']['signInUser']
    end
  end
end
