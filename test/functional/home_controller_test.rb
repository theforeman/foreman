require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should get settings" do
    get :settings
    assert_response :success
  end
  
end
