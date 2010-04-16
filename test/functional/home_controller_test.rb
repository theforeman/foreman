require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get settings" do
    get :settings, {}, set_session_user
    assert_response :success
  end
end
