require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  def user_with_viewer_rights_should_succeed_in_viewing_the_dashboard
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index
    assert_response :success
  end

  test "should redirect unknown users to signo when SSO allowed" do
    configure_sso
    @controller.env = @controller.request.env
    get :index
    assert_response :redirect
    assert @response.redirect_url.include?(Setting['signo_url'])
  end

  test "OpenID request should be made for known users to Signo when SSO allowed" do
    configure_sso
    request.cookies[:username] = 'admin'
    @controller.env = @controller.request.env
    get :index
    assert_response 401
    identifier = @response.headers.try(:[],"WWW-Authenticate")
    assert_equal "OpenID identifier=\"#{Setting['signo_url']}/user/admin\"", identifier
  end

  def configure_sso
    Setting['signo_sso']                  = true
    Setting["authorize_login_delegation"] = false
  end
end
