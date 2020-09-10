require 'test_helper'

class Api::V2::HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end
end
