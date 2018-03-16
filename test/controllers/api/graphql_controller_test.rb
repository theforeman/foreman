require 'test_helper'

class Api::GraphqlControllerTest < ActionController::TestCase
  test 'empty query' do
    post :execute, {}

    assert_response :success
    refute_empty json_errors
    assert_includes json_error_messages, 'No query string was present'
  end

  test 'siging user in' do
    user = FactoryBot.create(:user, :with_jwt_secret)
    query = <<-GRAPHQL
      mutation {
        signInUser(login: { username: "#{user.login}", password: "#{user.password}" }) {
          user_id
          token
        }
      }
    GRAPHQL
    post :execute, params: { query: query }

    assert_response :success
    assert json_data('signInUser')['token']
    assert_equal user.id.to_s, json_data('signInUser')['user_id']
  end

  test 'fetching current user' do
    user = setup_jwt_authorized_user
    query = <<-GRAPHQL
      query {
        currentUser() {
          user_id
        }
      }
    GRAPHQL
    post :execute, params: { query: query }

    assert_response :success
    assert_equal user.id.to_s, json_data('currentUser')['user_id']
  end
end
