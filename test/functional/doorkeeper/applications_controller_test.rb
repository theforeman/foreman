require 'test_helper'

class Doorkeeper::ApplicationsControllerTest < ActionController::TestCase

  test "admin should be able to view oauth applications" do
    session[:user] = users(:admin).id
    get :index
    assert_response :success
  end

  test "non-admin should not be able to view oauth applications" do
    session[:user] = users(:one).id
    get :index
    assert_redirected_to login_users_path
  end

end
