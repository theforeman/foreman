require 'test_helper'

class Api::V1::DashboardControllerTest < ActionController::TestCase


  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:report)
  end

  test "should get index with json result" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    dashboard = ActiveSupport::JSON.decode(@response.body)
    assert_operator(dashboard.length, :>, 0)
  end


end