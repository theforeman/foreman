require 'test_helper'

class UsergroupsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Usergroup.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Usergroup.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to usergroups_url
  end

  def test_edit
    get :edit, {:id => Usergroup.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Usergroup.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Usergroup.first, :usergroup => {:user_ids => ["",""], :usergroup_ids => ["",""]} }, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Usergroup.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Usergroup.first, :usergroup => {:user_ids => ["",""], :usergroup_ids => ["",""]} }, set_session_user
    assert_redirected_to usergroups_url
  end

  def test_destroy
    usergroup = Usergroup.first
    delete :destroy, {:id => usergroup}, set_session_user
    assert_redirected_to usergroups_url
    assert !Usergroup.exists?(usergroup.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a usergroup' do
    setup_user
    get :edit, {:id => Usergroup.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing usergroups' do
    setup_user
    get :index
    assert_response :success
  end
end
