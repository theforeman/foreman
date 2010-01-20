require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get errors" do
    get :errors
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

  test "should get active" do
    get :active
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

  test "should get out of sync" do
    get :OutOfSync
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end
end
