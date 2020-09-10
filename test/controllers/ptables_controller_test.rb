require 'test_helper'

class PtablesControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def setup
    @ptable = FactoryBot.create(:ptable)
  end

  test 'index' do
    get :index, session: set_session_user
    assert_template 'index'
  end

  test 'new' do
    get :new, session: set_session_user
    assert_template 'new'
  end

  test 'create_invalid' do
    Ptable.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :ptable => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  test 'create_valid' do
    Ptable.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :ptable => { :name => "dummy", :layout => "dummy"} }, session: set_session_user
    assert_redirected_to ptables_url
  end

  test 'edit' do
    get :edit, params: { :id => Ptable.first.id }, session: set_session_user
    assert_template 'edit'
  end

  test 'update_invalid' do
    Ptable.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Ptable.first.id, :ptable => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  test 'update_valid' do
    Ptable.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => Ptable.first.id, :ptable => {:name => "UpdatedDummy", :layout => "dummy_layout"} }, session: set_session_user
    assert_redirected_to ptables_url
  end

  test 'destroy' do
    ptable = Ptable.first
    ptable.hosts.delete_all
    ptable.hostgroups.delete_all
    delete :destroy, params: { :id => ptable }, session: set_session_user
    assert_redirected_to ptables_url
    assert !Ptable.exists?(ptable.id)
  end

  test "export" do
    get :export, params: { :id => @ptable.to_param }, session: set_session_user
    assert_response :success
    assert_equal 'text/plain', response.media_type
    User.current = users(:admin)
    assert_equal @ptable.to_erb, response.body
  end

  def setup_view_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a partition table' do
    setup_view_user
    get :edit, params: { :id => @ptable.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should fail to delete a partition table' do
    setup_view_user
    delete :destroy, params: { :id => @ptable.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should fail to create a partition table' do
    setup_view_user
    post :create, params: { :ptable => {:name => "dummy", :layout => "dummy"} }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing partition tables' do
    setup_view_user
    get :index, session: set_session_user
    assert_response :success
  end

  def setup_edit_user
    @user = User.find_by_login("one")
    role = FactoryBot.build(:role)
    role.add_permissions!([:view_locations, :assign_locations, :edit_locations, :view_organizations, :assign_organizations, :edit_organizations])
    @user.roles = [Role.default, Role.find_by_name('Viewer'), Role.find_by_name('Edit partition tables'), role]
  end

  test 'user with editing rights should succeed in editing a partition table' do
    setup_edit_user
    get :edit, params: { :id => @ptable.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'user with editing rights should succeed in deleting a partition table' do
    setup_edit_user
    delete :destroy, params: { :id => @ptable.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_redirected_to ptables_url
    assert_equal "Successfully deleted #{@ptable.name}.", flash[:success]
  end

  test 'user with editing rights should succeed in creating a partition table' do
    setup_edit_user
    post :create, params: { :ptable => {:name => "dummy", :layout => "dummy"} }, session: set_session_user.merge(:user => users(:one).id)
    assert_redirected_to ptables_url
    assert_equal "Successfully created dummy.", flash[:success]
  end

  test 'preview' do
    host = FactoryBot.create(:host, :managed, :operatingsystem => FactoryBot.create(:suse, :with_archs, :with_media))
    template = FactoryBot.create(:ptable)

    # works for given host
    post :preview, params: { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, session: set_session_user
    assert_equal host.hostname.to_s.to_json, @response.body

    # without host specified it uses first one
    post :preview, params: { :template => '<%= 1+1 -%>', :id => template }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+1 -%>' }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+ -%>', :id => template }, session: set_session_user
    assert_includes @response.body, 'parse error on value'
  end
end
