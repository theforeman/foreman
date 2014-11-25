require 'test_helper'

class PuppetclassesControllerTest < ActionController::TestCase
  include LookupKeysHelper
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_edit
    get :edit, {:id => Puppetclass.first.to_param}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Puppetclass.first.to_param, :puppetclass => {:name => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Puppetclass.first.to_param, :puppetclass => {:name => "Mrs. Piggy"}}, set_session_user
    assert "Mrs, Piggy", Puppetclass.first.name
    assert_redirected_to puppetclasses_url
  end

  def test_destroy
    puppetclass = Puppetclass.first
    delete :destroy, {:id => puppetclass.to_param}, set_session_user
    assert_redirected_to puppetclasses_url
    assert !Puppetclass.exists?(puppetclass.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a puppetclass' do
    setup_user
    get :edit, {:id => Puppetclass.first.to_param}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing puppetclasses' do
    setup_user
    get :index, {}, set_session_user
    assert_response :success
  end

  test 'new db rows are not added to HostClass when POST to parameters' do
    host = FactoryGirl.create(:host)
    puppetclass = puppetclasses(:two)  #puppetclass to be added to host
    host_puppetclass_ids = host.host_classes.pluck(:puppetclass_id)
    assert_difference('HostClass.count', 0) do
      post :parameters, {:id => puppetclass.id, :host_id => host.id, :host => {:puppetclass_ids => (host_puppetclass_ids + [puppetclass.id])}}, set_session_user
    end
  end

  test 'new db rows are not added to HostgroupClass when POST to parameters' do
    hostgroup = hostgroups(:common)
    puppetclass = puppetclasses(:two)  #puppetclass to be added to hostgroup
    hostgroup_puppetclass_ids = hostgroup.hostgroup_classes.pluck(:puppetclass_id)
    assert_difference('HostgroupClass.count', 0) do
      post :parameters, {:id => puppetclass.id, :host_id => hostgroup.id, :hostgroup => {:puppetclass_ids => (hostgroup_puppetclass_ids + [puppetclass.id])}}, set_session_user
    end
  end

  # NOTES: for tests below testing ajax POST to method parameters
  # puppetclass(:two) has TWO overridable lookup keys:  1) special_info and 2) custom_class_param
  # special_info is a smart_variable that is added independant of environment
  # custom_class_param is a smart_class_param for production environment only AND is marked as :override => TRUE
  test 'puppetclass lookup keys are added to partial _class_parameters on EXISTING host form through ajax POST to parameters' do
    host = FactoryGirl.create(:host, :environment => environments(:production))
    puppetclass = puppetclasses(:two)
    post :parameters, {:id => puppetclass.id, :host_id => host.id, :host => host.attributes }, set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, host)
    assert_equal 2, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("special_info")
    assert lookup_keys_added.map(&:key).include?("custom_class_param")
  end

  test 'puppetclass smart class parameters are NOT added if environment does not match' do
    # below is the same test as above, except environment is changed from production to global_puppetmaster, so custom_class_param is NOT added
    host = FactoryGirl.create(:host, :environment => environments(:production))
    puppetclass = puppetclasses(:two)
    post :parameters, {:id => puppetclass.id, :host_id => host.id, :host => host.attributes.merge!('environment_id' => environments(:global_puppetmaster).id) }, set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, assigns(:obj))
    assert_equal 1, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("special_info")
    refute lookup_keys_added.map(&:key).include?("custom_class_param")
  end


  test 'puppetclass lookup keys are added to partial _class_parameters on EXISTING hostgroup form through ajax POST to parameters' do
    hostgroup = hostgroups(:common)
    puppetclass = puppetclasses(:two)
    # host_id is posted instead of hostgroup_id per host_edit.js#load_puppet_class_parameters
    post :parameters, {:id => puppetclass.id, :host_id => hostgroup.id, :hostgroup => hostgroup.attributes }, set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, hostgroup)
    assert_equal 2, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("special_info")
    assert lookup_keys_added.map(&:key).include?("custom_class_param")
  end

  test 'puppetclass lookup keys are added to partial _class_parameters on NEW host form through ajax POST to parameters' do
    host = Host::Managed.new(:name => "new_host", :environment_id => environments(:production).id)
    puppetclass = puppetclasses(:two)
    post :parameters, {:id => puppetclass.id, :host_id => 'null', :host => host.attributes }, set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, host)
    assert_equal 2, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("special_info")
    assert lookup_keys_added.map(&:key).include?("custom_class_param")
  end

  test 'puppetclass lookup keys are added to partial _class_parameters on NEW hostgroup form through ajax POST to parameters' do
    hostgroup = Hostgroup.new(:name => "new_hostgroup", :environment_id => environments(:production).id)
    puppetclass = puppetclasses(:two)
    # host_id is posted instead of hostgroup_id per host_edit.js#load_puppet_class_parameters
    post :parameters, {:id => puppetclass.id, :host_id => 'null', :hostgroup => hostgroup.attributes }, set_session_user
    assert_response :success
    lookup_keys_added = overridable_lookup_keys(puppetclass, hostgroup)
    assert_equal 2, lookup_keys_added.count
    assert lookup_keys_added.map(&:key).include?("special_info")
    assert lookup_keys_added.map(&:key).include?("custom_class_param")
  end

  test "sorting by environment name on the index screen should work" do
    setup_user
    #environment_classes(:nine) which assigned puppetclasses(:three) with environments(:global_puppetmaster) broke test, so remove it
    environment_classes(:nine).destroy
    get :index, {:order => "environment ASC"}, set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).last
  end

  test "text filtering on the index screen should work" do
    setup_user
    get :index, {:search => "git"}, set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).first
  end

  test "predicate filtering on the index screen should work" do
    setup_user
    get :index, {:search => "environment = testing"}, set_session_user
    assert_equal puppetclasses(:three), assigns(:puppetclasses).first
  end

  def test_override_enable
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [env])
    refute pc.class_params.first.override
    post :override, {:id => pc.to_param, :enable => 'true'}, set_session_user
    assert pc.class_params.reload.first.override
    assert_match /overridden all parameters/, flash[:notice]
    assert_redirected_to puppetclasses_url
  end

  def test_override_disable
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [env])
    pc.class_params.first.update_attributes(:override => true)
    post :override, {:id => pc.to_param, :enable => 'false'}, set_session_user
    refute pc.class_params.reload.first.override
    assert_match /reset all parameters/, flash[:notice]
    assert_redirected_to puppetclasses_url
  end

  def test_override_none
    pc = FactoryGirl.create(:puppetclass)
    post :override, {:id => pc.to_param}, set_session_user
    assert_match /No parameters to override/, flash[:error]
    assert_redirected_to puppetclasses_url
  end
end
