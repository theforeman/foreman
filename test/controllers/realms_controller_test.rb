require 'test_helper'

class RealmsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Realm.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :realm => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Realm.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :realm => {:name => "MyRealm"} }, session: set_session_user
    assert_redirected_to realms_url
  end

  def test_edit
    get :edit, params: { :id => Realm.first }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Realm.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Realm.first.name, :realm => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Realm.any_instance.stubs(:valid?).returns(true)
    realm_id = Realm.unscoped.first.id
    proxy_id = SmartProxy.unscoped.first.id
    put :update, params: { :id => realm_id,
                           :realm => { :realm_proxy_id => proxy_id } }, session: set_session_user
    assert_equal proxy_id, Realm.unscoped.find(realm_id).realm_proxy_id
    assert_redirected_to realms_url
  end

  def test_destroy
    realm = Realm.first
    realm.hosts.clear
    realm.hostgroups.clear
    delete :destroy, params: { :id => realm }, session: set_session_user
    assert_redirected_to realms_url
    assert !Realm.exists?(realm.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_edit_a_realm
    setup_users
    get :edit, params: { :id => Realm.first }
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_realms
    setup_users
    get :index
    assert_response :success
  end
end
