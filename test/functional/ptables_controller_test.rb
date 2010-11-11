require 'test_helper'

class PtablesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_show_json
    get :show, {:id => Ptable.first.id}, :format => :json, :user => users(:admin).id
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal "default", json["ptable"]["name"]
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    post :create, {:ptable => {:name => "dummy", :layout => "dummy"}}, set_session_user
    assert_redirected_to ptables_url
  end

  def test_edit
    get :edit, {:id => Ptable.first.id}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Ptable.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Ptable.first.id}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Ptable.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Ptable.first.id}, set_session_user
    assert_redirected_to ptables_url
  end

  def test_destroy
    ptable = Ptable.first
    ptable.hosts = []
    delete :destroy, {:id => ptable}, set_session_user
    assert_redirected_to ptables_url
    assert !Ptable.exists?(ptable.id)
  end

  def setup_view_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a partition table' do
    setup_view_user
    get :edit, {:id => Ptable.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should fail to delete a partition table' do
    setup_view_user
    delete :destroy, {:id => Ptable.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should fail to create a partition table' do
    setup_view_user
    post :create, {:ptable => {:name => "dummy", :layout => "dummy"}}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing partition tables' do
    setup_view_user
    get :index
    assert_response :success
  end

  def setup_edit_user
    @user = User.find_by_login("one")
    @user.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer'), Role.find_by_name('Edit partition tables')]
    @request.session[:user] = @user.id
  end


  test 'user with editing rights should succeed in editing a partition table' do
    setup_edit_user
    get :edit, {:id => Ptable.first.id}
    assert_response :success
  end

  test 'user with editing rights should succeed in deleting a partition table' do
    setup_edit_user
    delete :destroy, {:id => Ptable.first.id}
    assert flash[:foreman_notice] = "Successfully destroyed partition table."
  end

  test 'user with editing rights should succeed in creating a partition table' do
    setup_edit_user
    post :create, {:ptable => {:name => "dummy", :layout => "dummy"}}
    assert flash[:foreman_notice] = "Successfully created partition table."
  end
end
