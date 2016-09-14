require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get status without an error" do
    get :status, {:format => "json"}
    assert_response :success
  end
end
