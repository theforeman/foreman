require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_show
    get :show, {:id => Audit.first}, set_session_user
    assert_template 'show'
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end
  def user_with_viewer_rights_should_fail_to edit_audit
    setup_user
    get :edit, {:id => Audit.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_succeed_in_viewing_audits
    setup_user
    get :index
    assert_response :success
  end
end
