require 'test_helper'

class SystemGroupsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_nest
    get :nest, {:id => SystemGroup.first.id}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    SystemGroup.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    SystemGroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, {"system_group" => {"name"=>"test_it", "group_parameters_attributes"=>{"1272344174448"=>{"name"=>"x", "value"=>"y", "_destroy"=>""}}, "puppetclass_ids"=>["", pc.id.to_s]}}, set_session_user
    assert_redirected_to system_groups_url
  end

  def test_clone
    get :clone, {:id => SystemGroup.first}, set_session_user
    assert_template 'new'
  end

  def test_edit
    get :edit, {:id => SystemGroup.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    SystemGroup.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => SystemGroup.first, :system_group => {}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    SystemGroup.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => SystemGroup.first, :system_group => {}}, set_session_user
    assert_redirected_to system_groups_url
  end

  def test_destroy
    system_group = system_groups(:unusual)
    delete :destroy, {:id => system_group.id}, set_session_user
    assert_redirected_to system_groups_url
    assert !SystemGroup.exists?(system_group.id)
  end

  def setup_user operation
    @request.session[:user] = users(:one).id
    @one = users(:one)
    as_admin do
      @one.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      role = Role.find_or_create_by_name :name => "system_groups"
      role.permissions = ["#{operation}_system_groups".to_sym]
      role.save!
      @one.roles << [role]
      @one.save!
    end
  end

  test 'user with viewer rights should fail to edit a system_group ' do
    setup_user "view"
    get :edit, {:id => SystemGroup.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing system_groups' do
    setup_user "view"
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'owners of a system_group up in the hierarchy get ownership of all children' do
    setup_user "create"
    as_admin do
      SystemGroup.new(:name => "root").save
      SystemGroup.find_by_name("root").users << @one
    end

    post :create, {"system_group" => {"name"=>"first" , "parent_id"=> SystemGroup.find_by_name("root").id}},
                  set_session_user.merge(:user => @one.id)
    assert_response :redirect

    post :create, {"system_group" => {"name"=>"second", "parent_id"=> SystemGroup.find_by_name("first").id}},
                  set_session_user.merge(:user => @one.id)

    assert_blank flash[:error]
    assert_response :redirect

    assert_equal @one, SystemGroup.find_by_name("first").users.first
    assert_equal @one, SystemGroup.find_by_name("second").users.first
  end

  test "blank root password submitted does not erase existing password" do
    system_group = system_groups(:common)
    old_root_pass = system_group.root_pass
    as_admin do
      put :update, {:commit => "Update", :id => system_group.id, :system_group => {:root_pass => ''} }, set_session_user
    end
    system_group = SystemGroup.find(system_group.id)
    assert_equal old_root_pass, system_group.root_pass
  end

  test 'users subscribed to all system_groups should be always added to system_group' do
    User.current = User.first
    one = users(:one)
    one.update_attributes(:subscribe_to_all_system_groups => true)

    post :create, { "system_group" => { "name"=>"first" } }, set_session_user
    post :create, { "system_group" => { "name"=>"second" } }, set_session_user

    assert_equal one, SystemGroup.find_by_name("first").users.first
    assert_equal one, SystemGroup.find_by_name("second").users.first
  end

end
