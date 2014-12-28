require 'test_helper'

class HostgroupsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
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
    post :create, {:hostgroup => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, {:hostgroup => {:name=>"test_it", :group_parameters_attributes=>{"1272344174448"=>{:name => "x", :value =>"y", :_destroy => ""}},
                   :puppetclass_ids=>["", pc.id.to_s], :realm_id => realms(:myrealm).id}}, set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_clone
    get :clone, {:id => Hostgroup.first}, set_session_user
    assert_template 'new'
  end

  def test_edit
    get :edit, {:id => Hostgroup.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Hostgroup.first, :hostgroup => { :name => Hostgroup.first.name }}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Hostgroup.first, :hostgroup => { :name => Hostgroup.first.name }}, set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_destroy
    hostgroup = hostgroups(:unusual)
    delete :destroy, {:id => hostgroup.id}, set_session_user
    assert_redirected_to hostgroups_url
    assert !Hostgroup.exists?(hostgroup.id)
  end

  def setup_user(operation, type = 'hostgroups')
    super
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

  test "blank root password submitted does not erase existing password" do
    hostgroup = hostgroups(:common)
    old_root_pass = hostgroup.root_pass
    as_admin do
      put :update, {:commit => "Update", :id => hostgroup.id, :hostgroup => {:root_pass => ''} }, set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert_equal old_root_pass, hostgroup.root_pass
  end

  test "hostgroup rename changes matcher" do
    hostgroup = hostgroups(:common)
    put :update, {:id => hostgroup.id, :hostgroup => {:name => 'new_common'}}, set_session_user
    assert_equal 'hostgroup=new_common', lookup_values(:hostgroupcommon).match
    assert_equal 'hostgroup=new_common', lookup_values(:four).match
  end

  test "hostgroup rename changes matcher" do
    hostgroup = hostgroups(:common)
    put :update, {:id => hostgroup.id, :hostgroup => {:name => 'new_common'}}, set_session_user
    assert_equal 'hostgroup=new_common', lookup_values(:hostgroupcommon).match
    assert_equal 'hostgroup=new_common', lookup_values(:four).match
  end

  test "hostgroup rename of parent changes matcher of parent and child hostgroup" do
    hostgroup = hostgroups(:parent)
    put :update, {:id => hostgroup.id, :hostgroup => {:name => 'new_parent'}}, set_session_user
    assert_equal 'hostgroup=new_parent', lookup_values(:five).match
    assert_equal 'hostgroup=new_parent/inherited', lookup_values(:six).match
  end

  test "hostgroup rename of child only changes matcher of child hostgroup" do
    hostgroup = hostgroups(:inherited)
    put :update, {:id => hostgroup.id, :hostgroup => {:name => 'new_child'}}, set_session_user
    assert_equal 'hostgroup=Parent/new_child', lookup_values(:six).match
  end


end
