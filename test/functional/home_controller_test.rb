require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get status without an error" do
    get :status, {:format => "json"}
    assert_response :success
  end

  test "should redirect to dashboard if home_page setting is blank" do
    get :index, {}, set_session_user
    assert_redirected_to dashboard_url
  end

  test "should redirect to custom path if custom user homepage setting is set" do
    assert User.find_by_login('secret_admin').update_attributes(:homepage => 'hostgroups')
    get :index, {}, set_session_user
    assert_redirected_to hostgroups_url
  end

  test "should redirect to dashboard path if no user homepage setting is set" do
    get :index, {}, set_session_user
    assert_redirected_to dashboard_url
  end


end
