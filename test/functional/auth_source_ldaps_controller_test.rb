require 'test_helper'

class AuthSourceLdapsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to auth_source_ldaps_url
  end

  def test_edit
    get :edit, {:id => AuthSourceLdap.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => AuthSourceLdap.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => AuthSourceLdap.first}, set_session_user
    assert_redirected_to auth_source_ldaps_url
  end

  def test_destroy
    auth_source_ldap = AuthSourceLdap.first
    delete :destroy, {:id => auth_source_ldap}, set_session_user
    assert_redirected_to auth_source_ldaps_url
    assert !AuthSourceLdap.exists?(auth_source_ldap.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_an_edit_authentication_source
    setup_user
    get :edit, {:id => AuthSourceLdap.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_authentication_sources
    setup_user
    get :index
    assert_response :success
  end
end
