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
end
