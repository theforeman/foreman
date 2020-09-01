require 'test_helper'

class Users::JwtControllerTest < ActionController::TestCase
  test '#create' do
    post :create, session: set_session_user
    assert_response :success
    assert_not_empty JSON.parse(@response.body)['jwt']
  end
end
