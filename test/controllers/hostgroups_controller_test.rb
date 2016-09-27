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
    post :create, {:hostgroup => {:name=>"test_it",
                                  :lookup_values_attributes=>{"0" => {"lookup_key_id" => lookup_keys(:common).id, "value" => "y",  "match" => "hostgroup=test_it"}},
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
    subnet = FactoryGirl.create(:subnet_ipv4)
    domain.subnets << subnet
    domain.save
    xhr :post, :domain_selected, {:id => Hostgroup.first, :hostgroup => {}, :domain_id => domain.id, :format => :json}, set_session_user
    assert_equal subnet.name, JSON.parse(response.body)[0]["subnet"]["name"]
    assert_equal subnet.unused_ip.suggest_new?, JSON.parse(response.body)[0]["subnet"]["unused_ip"]["suggest_new"]
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

  test 'user with view_params rights should see parameters in a hostgroup' do
    setup_user "edit"
    setup_user "view", "params"
    hg = FactoryGirl.create(:hostgroup, :with_parameter)
    get :edit, {:id => hg.id}, set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Global parameters']
  end

  test 'user without view_params rights should not see parameters in a hostgroup' do
    setup_user "edit"
    hg = FactoryGirl.create(:hostgroup, :with_parameter)
    get :edit, {:id => hg.id}, set_session_user.merge(:user => users(:one).id)
    assert_nil response.body['Global parameters']
  end

  describe "parent attributes" do
    before do
      @base = FactoryGirl.create(:hostgroup)
      @key1 = FactoryGirl.create(:global_lookup_key,:with_override, :key => "x")
      FactoryGirl.create(:lookup_value, :lookup_key_id => @key1.id, :value => "original", :match => @base.lookup_value_match)
      @key2 = FactoryGirl.create(:global_lookup_key,:with_override, :key => "y")
      FactoryGirl.create(:lookup_value, :lookup_key_id => @key2.id, :value => "originally", :match => @base.lookup_value_match)
      Hostgroup.any_instance.stubs(:valid?).returns(true)
    end

    it "creates a hostgroup with a parent parameter" do
      post :create, {"hostgroup" => {"name"=>"test_it", "parent_id" => @base.id, :realm_id => realms(:myrealm).id,
                                     :lookup_values_attributes => {"0" => {:lookup_key_id => @key1.id, :value =>"overridden", :match => "hostgroup=#{@base.name}/test_it"}}}}, set_session_user
      assert_redirected_to hostgroups_url
      hostgroup = Hostgroup.where(:name => "test_it").last
      assert_equal "overridden", hostgroup.parameters["x"]
    end

    it "updates a hostgroup with a parent parameter" do
      child = FactoryGirl.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end
      post :update, {"id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :lookup_values_attributes => {"0" => {:lookup_key_id => @key1.id, :value =>"overridden", :match => child.lookup_value_match}}}}, set_session_user
      assert_redirected_to hostgroups_url
      child.reload
      assert_equal "overridden", child.parameters["x"]
    end

    it "updates a hostgroup with a parent parameter, allows empty values" do
      child = FactoryGirl.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end
      post :update, {"id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :lookup_values_attributes => {"0" => {:lookup_key_id => @key1.id, :value =>nil, :match => child.lookup_value_match},
                                                                                        "1" => {:lookup_key_id => @key2.id, :value =>"overridden", :match => child.lookup_value_match}}}}, set_session_user
      assert_redirected_to hostgroups_url
      child.reload
      assert_equal "overridden", child.parameters["y"]
      assert_equal nil, child.parameters["x"]
    end

    it "changes the hostgroup's parent and check the parameters are updated" do
      child = FactoryGirl.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end

      new_parent = FactoryGirl.create(:hostgroup, :with_parameter)

      post :update, {"id" => child.id, "hostgroup" => {"name" => child.name, "parent_id" => new_parent.id}}, set_session_user

      assert_redirected_to hostgroups_url
      child.reload
      as_admin do
        assert_equal new_parent.lookup_values.first[:value], child.parameters[new_parent.lookup_values.first.key]
        assert_equal nil, child.parameters["x"]
      end
    end
  end
end
