require 'test_helper'

class Api::V2::PluginsControllerTest < ActionController::TestCase
  test "should get plugins " do
    get :index
    assigns(:plugins)
    assert_response :success
  end
end
