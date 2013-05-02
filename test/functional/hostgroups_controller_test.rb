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

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a hostgroup ' do
    setup_user
    get :edit, {:id => Hostgroup.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing hostgroups' do
    setup_user
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'owners of a hostgroup up in the hierarchy get ownership of all children' do
    User.current = User.first
    sample_user = users(:one)

    Hostgroup.new(:name => "root").save
    Hostgroup.find_by_name("root").users << sample_user

    post :create, {"hostgroup" => {"name"=>"first" , "parent_id"=> Hostgroup.find_by_name("root").id}}, set_session_user
    post :create, {"hostgroup" => {"name"=>"second", "parent_id"=> Hostgroup.find_by_name("first").id}}, set_session_user

    assert_equal sample_user,  Hostgroup.find_by_name("first").users.first
    assert_equal sample_user,  Hostgroup.find_by_name("second").users.first
  end

end
