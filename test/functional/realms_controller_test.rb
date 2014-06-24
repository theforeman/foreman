require 'test_helper'

class RealmsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Realm.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Realm.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to realms_url
  end

  def test_edit
    get :edit, {:id => Realm.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Realm.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Realm.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Realm.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Realm.first.name}, set_session_user
    assert_redirected_to realms_url
  end

  def test_destroy
    realm = Realm.first
    realm.hosts.clear
    realm.hostgroups.clear
    delete :destroy, {:id => realm.name}, set_session_user
    assert_redirected_to realms_url
    assert !Realm.exists?(realm.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_edit_a_realm
    setup_users
    get :edit, {:id => Realm.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_realms
    setup_users
    get :index
    assert_response :success
  end
end
