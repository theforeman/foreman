require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_show
    get :show, params: { :id => Audit.first }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  def test_show_diff
    audit = FactoryBot.create(:audit, :with_diff)
    get :show, params: { :id => audit.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
    assert_template '_diff'
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to(edit_audit)
    setup_user
    get :edit, params: { :id => Audit.first }
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_succeed_in_viewing_audits
    setup_user
    get :index
    assert_response :success
  end
end
