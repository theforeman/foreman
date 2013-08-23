require 'test_helper'

class Api::V2::LookupKeysControllerTest < ActionController::TestCase

  valid_attrs = { :key => 'testkey', :is_param => true }

  test "should get smart parameters for a specific host" do
    get :host_or_hostgroup_smart_parameters, {:host_id => hosts(:one).to_param}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "ssl_port", lookup_keys[0]['lookup_key']['key']
  end

  test "should get smart parameters for a specific hostgroup" do
    get :host_or_hostgroup_smart_parameters, {:hostgroup_id => hostgroups(:common).to_param}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "ssl_port", lookup_keys[0]['lookup_key']['key']
  end

  test "should get smart parameters for a specific puppetclass" do
    get :puppet_smart_parameters, {:puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "special_info", lookup_keys[0]['lookup_key']['key']
  end

  test "should get smart class parameters for a specific host" do
    get :host_or_hostgroup_smart_class_parameters, {:host_id => hosts(:one).to_param}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "cluster", lookup_keys[0]['lookup_key']['key']
  end

  test "should get smart class parameters for a specific hostgroup" do
    get :host_or_hostgroup_smart_class_parameters, {:hostgroup_id => hostgroups(:common).to_param}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "cluster", lookup_keys[0]['lookup_key']['key']
  end

  test "should get smart class parameters for a specific puppetclass and environment combination" do
    get :puppet_smart_class_parameters, {:puppetclass_id => puppetclasses(:two).to_param,
                                         :environment_id => environments(:production).to_param}
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
    assert_equal 1, lookup_keys.count
    assert_equal "custom_class_param", lookup_keys[0]['lookup_key']['key']
  end

  test "should create a smart variable" do
    assert_difference('LookupKey.count') do
      as_admin do
        post :create, { :lookup_key => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update smart variable" do
    put :update, { :id => lookup_keys(:one).to_param, :lookup_key => { :default_value => 8080 } }
    assert_response :success
  end

  test "should destroy lookup_keys" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, { :id => lookup_keys(:one).to_param }
    end
    assert_response :success
  end

end
