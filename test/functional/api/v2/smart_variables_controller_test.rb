require 'test_helper'

class Api::V2::SmartVariablesControllerTest < ActionController::TestCase

  test "should get all smart variables" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].length
  end

  test "should get smart variables for a specific host" do
    get :index, {:host_id => hosts(:one).to_param}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "ssl_port", results['results'][0]['variable']
  end

  test "should get smart variables for a specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "ssl_port", results['results'][0]['variable']
  end

  test "should get smart variables for a specific puppetclass" do
    get :index, {:puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "special_info", results['results'][0]['variable']
  end

  test "should create a smart variable" do
    assert_difference('LookupKey.count') do
      as_admin do
        valid_attrs = { :variable => 'test_smart_variable', :puppetclass_id => puppetclasses(:one).id }
        post :create, { :smart_variable => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should show specific smart variable" do
    get :show, {:id => lookup_keys(:two).to_param, :puppetclass_id => puppetclasses(:one).id}
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update smart variable" do
    orig_value = lookup_keys(:four).default_value
    put :update, { :id => lookup_keys(:four).to_param, :smart_variable => { :default_value => 'newstring' } }
    assert_response :success
    new_value = lookup_keys(:four).reload.default_value
    refute_equal orig_value, new_value
  end

  test "should destroy smart variable" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, { :id => lookup_keys(:four).to_param }
    end
    assert_response :success
  end

end
