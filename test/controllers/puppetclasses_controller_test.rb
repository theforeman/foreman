require 'test_helper'

class PuppetclassesControllerTest < ActionController::TestCase
  include LookupKeysHelper

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  def host_attributes(host)
    known_attrs = HostsController.host_params_filter.accessible_attributes(HostsController.parameter_filter_context)
    host.attributes.except('id', 'created_at', 'updated_at').slice(*known_attrs)
  end

  def hostgroup_attributes(hostgroup)
    known_attrs = HostgroupsController.hostgroup_params_filter.accessible_attributes(HostgroupsController.parameter_filter_context)
    hostgroup.attributes.except('id', 'created_at', 'updated_at', 'hosts_count', 'ancestry').slice(*known_attrs)
  end

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_edit
    get :edit, params: { :id => Puppetclass.first.to_param }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Puppetclass.first.to_param, :puppetclass => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    updated_puppetclass_id = Puppetclass.first.id
    put :update, params: { :id => updated_puppetclass_id, :puppetclass => {:name => 'foo'} }, session: set_session_user
    assert_equal 'foo', Puppetclass.find(updated_puppetclass_id).name
    assert_redirected_to puppetclasses_url
  end

  def test_destroy
    puppetclass = Puppetclass.first
    delete :destroy, params: { :id => puppetclass.to_param }, session: set_session_user
    assert_redirected_to puppetclasses_url
    assert !Puppetclass.exists?(puppetclass.id)
  end

  def setup_user(operation = nil, type = "", search = nil, user = :one)
    if operation.nil?
      @request.session[:user] = users(:one).id
      users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
    else
      super
    end
  end

  test 'user with viewer rights should fail to edit a puppetclass' do
    setup_user
    get :edit, params: { :id => Puppetclass.first.to_param }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing puppetclasses' do
    setup_user
    get :index, session: set_session_user
    assert_response :success
  end

  test 'new db rows are not added to HostClass when POST to parameters' do
    host = FactoryBot.create(:host)
    puppetclass = puppetclasses(:two)  # puppetclass to be added to host
    host_puppetclass_ids = host.host_classes.pluck(:puppetclass_id)
    assert_difference('HostClass.count', 0) do
      post :parameters, params: { :id => puppetclass.id, :host_id => host.id, :host => {:puppetclass_ids => (host_puppetclass_ids + [puppetclass.id])} }, session: set_session_user
    end
  end

  test 'new db rows are not added to HostgroupClass when POST to parameters' do
    hostgroup = hostgroups(:common)
    puppetclass = puppetclasses(:two)  # puppetclass to be added to hostgroup
    hostgroup_puppetclass_ids = hostgroup.hostgroup_classes.pluck(:puppetclass_id)
    assert_difference('HostgroupClass.count', 0) do
      post :parameters, params: { :id => puppetclass.id, :host_id => hostgroup.id, :hostgroup => {:puppetclass_ids => (hostgroup_puppetclass_ids + [puppetclass.id])} }, session: set_session_user
    end
  end

  # NOTES: for tests below testing ajax POST to method parameters
  # puppetclass(:two) has an overridable lookup key custom_class_param.
  # custom_class_param is a smart_class_param for production environment only AND is marked as :override => TRUE
  test 'puppetclass lookup keys are added to partial _class_parameters on EXISTING host form through ajax POST to parameters' do
    host = FactoryBot.create(:host, :environment => environments(:production))
    existing_host_attributes = host_attributes(host)
    puppetclass = puppetclasses(:two)
    post :parameters, params: { :id => puppetclass.id, :host_id => host.id,
                                :host => existing_host_attributes }, session: set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, host)
    assert_equal 1, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("custom_class_param")
  end

  test 'puppetclass smart class parameters are NOT added if environment does not match' do
    # below is the same test as above, except environment is changed from production to global_puppetmaster, so custom_class_param is NOT added
    host = FactoryBot.create(:host, :environment => environments(:production))
    existing_host_attributes = host_attributes(host)
    existing_host_attributes['environment_id'] = environments(:global_puppetmaster).id
    puppetclass = puppetclasses(:two)
    post :parameters, params: { :id => puppetclass.id, :host_id => host.id,
                                :host => existing_host_attributes }, session: set_session_user
    assert_response :success
    as_admin do
      lookup_keys_added = overridable_lookup_keys(puppetclass, assigns(:obj))
      assert_equal 0, lookup_keys_added.count
      refute lookup_keys_added.map(&:key).include?("custom_class_param")
    end
  end

  test 'puppetclass lookup keys are added to partial _class_parameters on EXISTING hostgroup form through ajax POST to parameters' do
    hostgroup = hostgroups(:common)
    puppetclass = puppetclasses(:two)
    existing_hostgroup_attributes = hostgroup_attributes(hostgroup)
    # host_id is posted instead of hostgroup_id per host_edit.js#load_puppet_class_parameters
    post :parameters, params: { :id => puppetclass.id, :host_id => hostgroup.id,
                                :hostgroup => existing_hostgroup_attributes }, session: set_session_user
    assert_response :success
    as_admin do
      lookup_keys_added = overridable_lookup_keys(puppetclass, hostgroup)
      assert_equal 1, lookup_keys_added.count
      assert lookup_keys_added.map(&:key).include?("custom_class_param")
    end
  end

  test 'puppetclass lookup keys are added to partial _class_parameters on NEW host form through ajax POST to parameters' do
    host = Host::Managed.new(:name => "new_host", :environment_id => environments(:production).id)
    new_host_attributes = host_attributes(host)
    puppetclass = puppetclasses(:two)
    post :parameters, params: { :id => puppetclass.id, :host_id => 'undefined',
                                :host => new_host_attributes }, session: set_session_user
    assert_response :success
    as_admin do
      lookup_keys_added = overridable_lookup_keys(puppetclass, host)
      assert_equal 1, lookup_keys_added.count
      assert lookup_keys_added.map(&:key).include?("custom_class_param")
    end
  end

  test 'puppetclass lookup keys are added to partial _class_parameters on NEW hostgroup form through ajax POST to parameters' do
    hostgroup = Hostgroup.new(:name => "new_hostgroup", :environment_id => environments(:production).id)
    new_hostgroup_attributes = hostgroup_attributes(hostgroup)
    puppetclass = puppetclasses(:two)
    # host_id is posted instead of hostgroup_id per host_edit.js#load_puppet_class_parameters
    post :parameters, params: { :id => puppetclass.id, :host_id => 'undefined',
                                :hostgroup => new_hostgroup_attributes }, session: set_session_user
    assert_response :success
    as_admin do
      lookup_keys_added = overridable_lookup_keys(puppetclass, hostgroup)
      assert_equal 1, lookup_keys_added.count
      assert lookup_keys_added.map(&:key).include?("custom_class_param")
    end
  end

  test "sorting by environment name on the index screen should work" do
    setup_user
    # environment_classes(:nine) which assigned puppetclasses(:three) with environments(:global_puppetmaster) broke test, so remove it
    environment_classes(:nine).destroy
    get :index, params: { :order => "environment ASC" }, session: set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).last
  end

  test "text filtering on the index screen should work" do
    setup_user
    get :index, params: { :search => "git" }, session: set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).first
  end

  test "predicate filtering on the index screen should work" do
    setup_user
    get :index, params: { :search => "environment = testing" }, session: set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).first
  end

  def test_override_enable
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :with_parameters, :environments => [env])
    refute pc.class_params.first.override
    post :override, params: { :id => pc.to_param, :enable => 'true' }, session: set_session_user
    assert pc.class_params.reload.first.override
    assert_match /overridden all parameters/, flash[:success]
    assert_redirected_to puppetclasses_url
  end

  def test_override_disable
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :with_parameters, :environments => [env])
    pc.class_params.first.update(:override => true)
    post :override, params: { :id => pc.to_param, :enable => 'false' }, session: set_session_user
    refute pc.class_params.reload.first.override
    assert_match /reset all parameters/, flash[:success]
    assert_redirected_to puppetclasses_url
  end

  def test_override_none
    pc = FactoryBot.create(:puppetclass)
    post :override, params: { :id => pc.to_param }, session: set_session_user
    assert_match /No parameters to override/, flash[:error]
    assert_redirected_to puppetclasses_url
  end

  test 'user with edit_puppetclasses permission should succeed in overriding all parameters' do
    env = FactoryBot.create(:environment,
      :organizations => [users(:one).organizations.first],
      :locations => [users(:one).locations.first])
    pc = FactoryBot.create(:puppetclass, :with_parameters, :environments => [env])
    setup_user "edit", "puppetclasses"
    refute pc.class_params.first.override
    post :override, params: { :id => pc.to_param, :enable => 'true' }, session: set_session_user.merge(:user => users(:one).id)
    assert_match /overridden all parameters/, flash[:success]
    assert_redirected_to puppetclasses_url
  end

  test 'user without edit_puppetclasses permission should fail in overriding all parameters' do
    env = FactoryBot.create(:environment,
      :organizations => [users(:one).organizations.first],
      :locations => [users(:one).locations.first])
    pc = FactoryBot.create(:puppetclass, :with_parameters, :environments => [env])
    setup_user "view", "puppetclasses"
    refute pc.class_params.first.override
    post :override, params: { :id => pc.to_param, :enable => 'true' }, session: set_session_user.merge(:user => users(:one).id)
    assert_match /You are not authorized to perform this action/, response.body
  end
end
