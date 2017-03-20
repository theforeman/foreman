require 'test_helper'

class Api::V1::DashboardControllerTest < ActionController::TestCase
  test "should get index with json result" do
    get :index
    assert_response :success
    dashboard = ActiveSupport::JSON.decode(@response.body)
    assert_operator(dashboard.length, :>, 0)
  end
end
