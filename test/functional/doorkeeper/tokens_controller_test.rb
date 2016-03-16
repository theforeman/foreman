require 'test_helper'

class Doorkeeper::TokensControllerTest < ActionController::TestCase

  test "should return a token for valid user credentials" do
    user = users(:admin)
    User.stubs(:try_to_login).returns(user)
    post :create, { :username => user.login, :password => 'doesntmatter', :grant_type => 'password' }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal ['access_token', 'token_type', 'expires_in'], response.keys
    refute_equal 64, response['access_token'].length
    assert_equal 'bearer', response['token_type']
    assert_equal 7200, response['expires_in']
  end

  test "should NOT return a token for INvalid user credentials" do
    User.stubs(:try_to_login).returns(nil)
    post :create, { :username => 'admin', :password => 'doesntmatter', :grant_type => 'password' }
    assert_response 401
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal "invalid_grant", response['error']
  end

end
