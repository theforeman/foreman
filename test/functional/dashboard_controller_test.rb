require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "should get errors" do
    get :errors, {}, set_session_user
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

  test "should get active" do
    get :active, {}, set_session_user
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

  test "should get out of sync" do
    get :OutOfSync, {}, set_session_user
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

  test "should get disabled hosts" do
    get :disabled, {}, set_session_user
    assert_response :success
    assert_template :partial => "hosts/_minilist"
  end

end
