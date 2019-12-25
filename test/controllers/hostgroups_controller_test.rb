require 'test_helper'
require 'pagelets_test_helper'
require 'nokogiri'

class HostgroupsControllerTest < ActionController::TestCase
  include PageletsIsolation

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_nest
    get :nest, params: { :id => hostgroups(:common).id }, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Hostgroup.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :hostgroup => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Hostgroup.any_instance.stubs(:valid?).returns(true)
    pc = Puppetclass.first
    post :create, params: { :hostgroup => {:name => "test_it", :group_parameters_attributes => {"1272344174448" => {:name => "x", :value => "y", :_destroy => ""}},
                   :puppetclass_ids => ["", pc.id.to_s], :realm_id => realms(:myrealm).id} }, session: set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_clone
    get :clone, params: { :id => hostgroups(:common) }, session: set_session_user
    assert_template 'new'
  end

  def test_edit
    get :edit, params: { :id => hostgroups(:common) }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    put :update, params: { :id => hostgroups(:common), :hostgroup => { :name => '' } }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    put :update, params: { :id => hostgroups(:common), :hostgroup => { :name => hostgroups(:common).name } }, session: set_session_user
    assert_redirected_to hostgroups_url
  end

  def test_destroy
    hostgroup = hostgroups(:unusual)
    delete :destroy, params: { :id => hostgroup.id }, session: set_session_user
    assert_redirected_to hostgroups_url
    assert !Hostgroup.exists?(hostgroup.id)
  end

  def setup_user(operation, type = 'hostgroups')
    super
  end

  test 'user with viewer rights should fail to edit a hostgroup ' do
    setup_user "view"
    get :edit, params: { :id => hostgroups(:common).id }, session: set_session_user.merge(:user => users(:one).id)
    assert_response :forbidden
  end

  test 'user with viewer rights should succeed in viewing hostgroups' do
    setup_user "view"
    get :index, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'csv export works' do
    host = FactoryBot.create(:host, :with_hostgroup)
    get :index, params: { :format => 'csv' }, session: set_session_user
    assert_response :success
    assert response.body.include? "#{host.hostgroup.title},1,1"
  end

  test "hostgroup update without root password in the params does not erase existing password" do
    hostgroup = hostgroups(:common)
    old_root_pass = hostgroup.root_pass
    as_admin do
      put :update, params: { :commit => "Update", :id => hostgroup.id, :hostgroup => {:name => hostgroup.name} }, session: set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert_equal old_root_pass, hostgroup.root_pass
  end

  test 'blank root password submitted does erase existing password' do
    hostgroup = hostgroups(:common)
    as_admin do
      put :update, params: { :commit => "Update", :id => hostgroup.id, :hostgroup => {:root_pass => '', :name => hostgroup.name} }, session: set_session_user
    end
    hostgroup = Hostgroup.find(hostgroup.id)
    assert hostgroup.root_pass.empty?
  end

  test "hostgroup rename changes matcher" do
    hostgroup = hostgroups(:common)
    put :update, params: { :id => hostgroup.id, :hostgroup => {:name => 'new_common'} }, session: set_session_user
    assert_equal 'hostgroup=new_common', lookup_values(:hostgroupcommon).match
    assert_equal 'hostgroup=new_common', lookup_values(:four).match
  end

  test "hostgroup rename changes matcher" do
    hostgroup = hostgroups(:common)
    put :update, params: { :id => hostgroup.id, :hostgroup => {:name => 'new_common'} }, session: set_session_user
    assert_equal 'hostgroup=new_common', lookup_values(:hostgroupcommon).match
    assert_equal 'hostgroup=new_common', lookup_values(:four).match
  end

  test "hostgroup rename of parent changes matcher of parent and child hostgroup" do
    hostgroup = hostgroups(:parent)
    put :update, params: { :id => hostgroup.id, :hostgroup => {:name => 'new_parent'} }, session: set_session_user
    assert_equal 'hostgroup=new_parent', lookup_values(:five).match
    assert_equal 'hostgroup=new_parent/inherited', lookup_values(:six).match
  end

  test "hostgroup rename of child only changes matcher of child hostgroup" do
    hostgroup = hostgroups(:inherited)
    put :update, params: { :id => hostgroup.id, :hostgroup => {:name => 'new_child'} }, session: set_session_user
    assert_equal 'hostgroup=Parent/new_child', lookup_values(:six).match
  end

  test "domain_selected should return subnets" do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4)
    domain.subnets << subnet
    domain.save
    post :domain_selected, params: {:id => hostgroups(:common), :hostgroup => {}, :domain_id => domain.id, :format => :json}, session: set_session_user, xhr: true
    assert_equal subnet.name, JSON.parse(response.body)[0]["subnet"]["name"]
    assert_equal subnet.unused_ip.suggest_new?, JSON.parse(response.body)[0]["subnet"]["unused_ip"]["suggest_new"]
  end

  test "domain_selected should return empty on no domain_id" do
    post :domain_selected, params: {:id => hostgroups(:common), :hostgroup => {}, :format => :json, :domain_id => nil}, session: set_session_user, xhr: true
    assert_response :success
    assert_empty JSON.parse(response.body)
  end

  test "architecture_selected should not fail when no architecture selected" do
    post :architecture_selected, params: { :id => hostgroups(:common), :hostgroup => { :architecture_id => nil }}, session: set_session_user
    assert_response :success
    assert_template :partial => "common/os_selection/_architecture"
  end

  describe '#environment_selected' do
    setup do
      @environment = FactoryBot.create(:environment)
      @puppetclass = FactoryBot.create(:puppetclass)
      @hostgroup = FactoryBot.create(:hostgroup, :environment => @environment)
      @params = {
        id: @hostgroup.id,
        hostgroup: {
          name: @hostgroup.name,
          environment_id: "",
          puppetclass_ids: [@puppetclass.id],
        },
      }
    end

    test "should return the selected puppet classes on environment change" do
      assert_equal 0, @hostgroup.puppetclasses.length

      post :environment_selected, params: @params, session: set_session_user
      assert_equal(1, assigns(:hostgroup).puppetclasses.length)
      assert_include assigns(:hostgroup).puppetclasses, @puppetclass
    end

    context 'no environment_id param is set' do
      test 'it will take the hostgroup params environment_id' do
        other_environment = FactoryBot.create(:environment)
        @params[:hostgroup][:environment_id] = other_environment.id

        post :environment_selected, params: @params, session: set_session_user
        assert_equal assigns(:environment), other_environment
      end
    end

    test 'should not escape lookup values on environment change' do
      hostgroup = FactoryBot.create(:hostgroup, :environment => @environment, :puppetclass_ids => [@puppetclass.id])
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'array',
                                     :default_value => ['a', 'b'], :override => true, :puppetclass => @puppetclass)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :match => "hostgroup=#{hostgroup.name}", :value => ["c", "d"])

      FactoryBot.create(:environment_class, :puppetclass => @puppetclass, :environment => @environment, :puppetclass_lookup_key => lookup_key)

      # sending exactly what the host form would send which is lookup_value.value_before_type_cast
      lk = {"lookup_values_attributes" => {lookup_key.id.to_s => {"value" => lookup_value.value_before_type_cast, "id" => lookup_value.id, "lookup_key_id" => lookup_key.id, "_destroy" => false}}}

      params = {
        hostgroup_id: hostgroup.id,
        hostgroup: hostgroup.attributes.merge(lk),
      }

      # environment change calls puppetclass_parameters which caused the extra escaping
      post :puppetclass_parameters, params: params, session: set_session_user, xhr: true

      # if this was escaped during refresh_host the value in response.body after unescapeHTML would include "[\\\"c\\\",\\\"d\\\"]"
      assert_includes CGI.unescapeHTML(response.body), "[\"c\",\"d\"]"
    end
  end

  test 'user with view_params rights should see parameters in a hostgroup' do
    hg = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "edit"
    setup_user "view", "params"
    get :edit, params: { :id => hg.id }, session: set_session_user.merge(:user => users(:one).id)
    html_doc = Nokogiri::HTML(response.body)
    assert_not_nil html_doc.css('div#global_parameters_table')
  end

  test 'user without view_params rights should not see parameters in a hostgroup' do
    hg = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "edit"
    get :edit, params: { :id => hg.id }, session: set_session_user.merge(:user => users(:one).id)
    html_doc = Nokogiri::HTML(response.body)
    assert_not_nil html_doc.css('div#global_parameters_table')
  end

  describe "parent attributes" do
    before do
      @base = FactoryBot.create(:hostgroup)
      @base.group_parameters << GroupParameter.create(:name => "x", :value => "original")
      @base.group_parameters << GroupParameter.create(:name => "y", :value => "originally")
      Hostgroup.any_instance.stubs(:valid?).returns(true)
    end

    it "creates a hostgroup with a parent parameter" do
      post :create, params: { "hostgroup" => {"name" => "test_it", "parent_id" => @base.id, :realm_id => realms(:myrealm).id,
                                     :group_parameters_attributes => {"0" => {:name => "x", :value => "overridden", :_destroy => ""}}} }, session: set_session_user
      assert_redirected_to hostgroups_url
      hostgroup = Hostgroup.unscoped.where(:name => "test_it").last
      as_admin do
        assert_equal "overridden", hostgroup.parameters["x"]
      end
    end

    it "updates a hostgroup with a parent parameter" do
      child = FactoryBot.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end
      post :update, params: { "id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :group_parameters_attributes => {"0" => {:name => "x", :value => "overridden", :_destroy => ""}}} }, session: set_session_user
      assert_redirected_to hostgroups_url
      as_admin do
        child.reload
        assert_equal "overridden", child.parameters["x"]
      end
    end

    it "updates a hostgroup with a parent parameter, allows empty values" do
      child = FactoryBot.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end
      post :update, params: { "id" => child.id, "hostgroup" => {"name" => child.name,
                                                       :group_parameters_attributes => {"0" => {:name => "x", :value => "", :_destroy => ""},
                                                                                        "1" => {:name => "y", :value => "overridden", :_destroy => ""}}} }, session: set_session_user
      assert_redirected_to hostgroups_url
      as_admin do
        child.reload
        assert_equal "overridden", child.parameters["y"]
        assert_equal "", child.parameters["x"]
      end
    end

    it "changes the hostgroup's parent and check the parameters are updated" do
      child = FactoryBot.create(:hostgroup, :parent => @base)
      as_admin do
        assert_equal "original", child.parameters["x"]
      end

      new_parent = FactoryBot.create(:hostgroup)
      new_parent.group_parameters << GroupParameter.create(:name => "z", :value => "original")

      post :update, params: { "id" => child.id, "hostgroup" => {"name" => child.name, "parent_id" => new_parent.id} }, session: set_session_user

      assert_redirected_to hostgroups_url
      child.reload
      as_admin do
        assert_equal "original", child.parameters["z"]
        assert_nil child.parameters["x"]
      end
    end
  end

  context 'with pagelets' do
    setup do
      @controller.prepend_view_path File.expand_path('../static_fixtures', __dir__)
      Pagelets::Manager.add_pagelet('hostgroups/_form', :main_tabs,
        :name => 'TestTab',
        :id => 'my-special-id',
        :partial => 'views/test')
    end

    test '#new renders a pagelet tab' do
      get :new, session: set_session_user
      assert @response.body.match /id='my-special-id'/
    end

    test '#edit renders a pagelet tab' do
      get :edit, params: { :id => Hostgroup.first.to_param }, session: set_session_user
      assert @response.body.match /id='my-special-id'/
    end
  end
end
