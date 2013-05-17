require 'test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
    assert hostgroups.is_a?(Array)
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_nest
    get :nest, {:id => Hostgroup.first.id}, set_session_user
    assert_template 'new'
  end


  def test_create_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, {"hostgroup" => {"name"=>"test_it", "group_parameters_attributes"=>{"1272344174448"=>{"name"=>"x", "value"=>"y", "_destroy"=>""}}, "puppetclass_ids"=>["", pc.id.to_s]}}, set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_clone
    get :clone, {:id => Hostgroup.first}, set_session_user
    assert_template 'new'
  end

  def test_create_valid_json
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, {:format => "json", "hostgroup" => {"name"=>"test_it", "group_parameters_attributes"=>{"1272344174448"=>{"name"=>"x", "value"=>"y", "_destroy"=>""}}, "puppetclass_ids"=>["", pc.id.to_s]}}, set_session_user
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal "test_it", template["hostgroup"]["name"]
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Hostgroup.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Hostgroup.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Hostgroup.first}, set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_update_valid_json
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Hostgroup.first}, set_session_user
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_destroy
    hostgroup = hostgroups(:unusual)
    delete :destroy, {:id => hostgroup.id}, set_session_user
    assert_redirected_to hostgroups_url
    assert !Hostgroup.exists?(hostgroup.id)
  end

  def test_destroy_json
    hostgroup = hostgroups(:common)
    delete :destroy, {:format => "json", :id => hostgroup.id}, set_session_user
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Hostgroup.exists?(hostgroup.id)
  end

  def setup_user operation
    @request.session[:user] = users(:one).id
    @one = users(:one)
    as_admin do
      @one.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      role = Role.find_or_create_by_name :name => "hostgroups"
      role.permissions = ["#{operation}_hostgroups".to_sym]
      role.save!
      @one.roles << [role]
      @one.save!
    end
  end

  test 'user with viewer rights should fail to edit a hostgroup ' do
    setup_user "view"
    get :edit, {:id => Hostgroup.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing hostgroups' do
    setup_user "view"
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'owners of a hostgroup up in the hierarchy get ownership of all children' do
    setup_user "create"
    as_admin do
      Hostgroup.new(:name => "root").save
      Hostgroup.find_by_name("root").users << @one
    end

    post :create, {"hostgroup" => {"name"=>"first" , "parent_id"=> Hostgroup.find_by_name("root").id}},
                  set_session_user.merge(:user => @one.id)
    assert_response :redirect

    post :create, {"hostgroup" => {"name"=>"second", "parent_id"=> Hostgroup.find_by_name("first").id}},
                  set_session_user.merge(:user => @one.id)

    assert_blank flash[:error]
    assert_response :redirect

    assert_equal @one, Hostgroup.find_by_name("first").users.first
    assert_equal @one, Hostgroup.find_by_name("second").users.first
  end

  test "blank root password submitted does not erase existing password" do
    hostgroup = hostgroups(:common)
    old_root_pass = hostgroup.root_pass
    as_admin do
      put :update, {:commit => "Update", :id => hostgroup.id, :hostgroup => {:root_pass => ''} }, set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert_equal old_root_pass, hostgroup.root_pass
  end

end
