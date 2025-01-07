require 'test_helper'

class Api::V2::RegistrationTokensControllerTest < ActionController::TestCase
  test 'user shall invalidate tokens for self' do
    user = users(:one)
    FactoryBot.create(:jwt_secret, token: 'test_jwt_secret', user: user)
    delete :invalidate_jwt, params: { :id => user.id.to_s}, session: set_session_user(user)
    user.reload
    assert_response :success
    assert_nil user.jwt_secret
  end

  test 'user with edit permission should be able to invalidate jwt for another user' do
    setup_user 'edit', 'users'
    user = users(:one)
    FactoryBot.create(:jwt_secret, token: 'test_jwt_secret', user: user)
    delete :invalidate_jwt_tokens, params: { :search => "id ^ (#{user.id})"}, session: set_session_user(User.current)
    user.reload
    assert_response :success
    assert_nil user.jwt_secret
  end

  test 'user without edit permission should not be able to invalidate jwt for another user' do
    User.current = users(:one)
    user = users(:two)
    FactoryBot.create(:jwt_secret, token: 'test_jwt_secret', user: user)
    delete :invalidate_jwt_tokens, params: { :search => "id ^ (#{user.id})"}, session: set_session_user(User.current)
    user.reload
    assert_response :forbidden
    assert_not_nil user.jwt_secret
    response = JSON.parse(@response.body)
    assert_equal "Missing one of the required permissions: edit_users", response['error']['details']
  end

  test 'invalidating jwt should fail without search params' do
    setup_user 'edit', 'users'
    user = users(:two)
    FactoryBot.create(:jwt_secret, token: 'test_jwt_secret', user: user)
    delete :invalidate_jwt_tokens, session: set_session_user(User.current)
    user.reload
    assert_response :error
    assert_not_nil user.jwt_secret
    response = JSON.parse(@response.body)
    assert_equal "ERF42-7534 [Foreman::Exception]: Please provide search parameter", response['error']['message']
  end
end
