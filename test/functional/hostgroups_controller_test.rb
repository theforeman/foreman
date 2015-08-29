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
    put :update, {:id => Hostgroup.first, :hostgroup => { :name => '' }}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
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

  test "hostgroup update without root password in the params does not erase existing password" do
    hostgroup = hostgroups(:common)
    old_root_pass = hostgroup.root_pass
    as_admin do
      put :update, {:commit => "Update", :id => hostgroup.id, :hostgroup => {:name => hostgroup.name} }, set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert_equal old_root_pass, hostgroup.root_pass
  end

  test 'blank root password submitted does erase existing password' do
    hostgroup = hostgroups(:common)
    as_admin do
      put :update, {:commit => "Update", :id => hostgroup.id, :hostgroup => {:root_pass => '', :name => hostgroup.name} }, set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert hostgroup.root_pass.empty?
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

  test "domain_selected should return subnets" do
    domain = FactoryGirl.create(:domain)
    subnet = FactoryGirl.create(:subnet)
    domain.subnets << subnet
    domain.save
    xhr :post, :domain_selected, {:id => Hostgroup.first, :hostgroup => {}, :domain_id => domain.id, :format => :json}, set_session_user
    assert_equal subnet.name,  JSON.parse(response.body)[0]["subnet"]["name"]
  end

  test "domain_selected should return empty on no domain_id" do
    xhr :post, :domain_selected, {:id => Hostgroup.first, :hostgroup => {}, :format => :json, :domain_id => nil}, set_session_user
    assert_response :success
    assert_empty JSON.parse(response.body)
  end

  test "architecture_selected should not fail when no architecture selected" do
    post :architecture_selected, {:id => Hostgroup.first, :hostgroup => {}, :architecture_id => nil}, set_session_user
    assert_response :success
    assert_template :partial => "common/os_selection/_architecture"
  end

  test "current_parameters should not fail on when hostgoup_parent_id parameter missing" do
    xhr :post, :current_parameters, {:hostgroup_id => Hostgroup.first, :hostgroup_parent_id => '', :hostgroup => {}}, set_session_user
    assert_response :success
    assert_template :partial => "common_parameters/_inherited_parameters"
  end

  test "current_parameters should not fail on new hostgroup" do
    xhr :post, :current_parameters, {:hostgroup_id => "null", :hostgroup_parent_id => Hostgroup.first, :hostgroup => {}}, set_session_user
    assert_response :success
    assert_template :partial => "common_parameters/_inherited_parameters"
  end

  test "should return the selected puppet classes on environment change" do
    env = FactoryGirl.create(:environment)
    klass = FactoryGirl.create(:puppetclass)
    hg = FactoryGirl.create(:hostgroup, :environment => env)
    assert_equal 0, hg.puppetclasses.length
    post :environment_selected, { :id => hg.id,
                                  :hostgroup => { :name => hg.name,
                                                  :puppetclass_ids => [klass.id],
                                                  :environment_id => "" }}, set_session_user
    assert_equal(1, (assigns(:hostgroup).puppetclasses.length))
  end

  describe "parent attributes" do
    before do
      @base = FactoryGirl.create(:hostgroup)
      @base.group_parameters << GroupParameter.create(:name => "x", :value => "original")
      @base.group_parameters << GroupParameter.create(:name => "y", :value => "originally")
      Hostgroup.any_instance.stubs(:valid?).returns(true)
    end

    it "creates a hostgroup with a parent parameter" do
      post :create, {"hostgroup" => {"name"=>"test_it", "parent_id" => @base.id, :realm_id => realms(:myrealm).id,
                                     :group_parameters_attributes => {"new_0" => {:name => "x", :value =>"overridden", :_destroy => ""}}}}, set_session_user
      assert_redirected_to hostgroups_url
      hostgroup = Hostgroup.where(:name => "test_it").last
      assert_equal "overridden", hostgroup.parameters["x"]
    end

    it "updates a hostgroup with a parent parameter" do
      child = FactoryGirl.create(:hostgroup, :parent => @base)
      assert_equal "original", child.parameters["x"]
      post :update, {"id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :group_parameters_attributes => {"new_0" => {:name => "x", :value =>"overridden", :_destroy => ""}}}}, set_session_user
      assert_redirected_to hostgroups_url
      child.reload
      assert_equal "overridden", child.parameters["x"]
    end

    it "updates a hostgroup with a parent parameter, allows empty values" do
      child = FactoryGirl.create(:hostgroup, :parent => @base)
      assert_equal "original", child.parameters["x"]
      post :update, {"id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :group_parameters_attributes => {"new_0" => {:name => "x", :value => nil, :_destroy => ""},
                                                                                        "new_1" => {:name => "y", :value => "overridden", :_destroy => ""}}}}, set_session_user
      assert_redirected_to hostgroups_url
      child.reload
      assert_equal "overridden", child.parameters["y"]
      assert_equal nil, child.parameters["x"]
    end
  end
end
