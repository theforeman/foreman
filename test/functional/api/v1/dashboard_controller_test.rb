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
      get :index, {}, set_session_user
    end
    assert_response :success
    dashboard = ActiveSupport::JSON.decode(@response.body)
    assert !dashboard.empty?
  end


end