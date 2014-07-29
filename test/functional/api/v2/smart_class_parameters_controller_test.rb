require 'test_helper'

class Api::V2::SmartClassParametersControllerTest < ActionController::TestCase

  test "should get all smart class parameters" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].length
  end

  test "should get smart class parameters for a specific host" do
    get :index, {:host_id => hosts(:one).to_param}
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "cluster", results['results'][0]['parameter']
  end

  test "should get smart class parameters for a specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param}
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "cluster", results['results'][0]['parameter']
  end

  test "should get smart class parameters for a specific puppetclass" do
    get :index, {:puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "custom_class_param", results['results'][0]['parameter']
  end

  test "should get smart class parameters for a specific environment" do
    get :index, {:environment_id => environments(:production).id}
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal ["cluster", "custom_class_param"], results['results'].map {|cp| cp["parameter"] }.sort
  end

  test "should get smart class parameters for a specific environment and puppetclass combination" do
    get :index, {:environment_id => environments(:production).id, :puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "custom_class_param", results['results'][0]['parameter']
  end

  test "should show specific smart class parameter by id" do
    get :show, {:id => lookup_keys(:five).to_param, :puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show specific smart class parameter by parameter name when it is unique" do
    get :show, {:id => lookup_keys(:complex).key}
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show specific smart class parameter by parameter name even if it is not unique" do
    get :show, {:id => lookup_keys(:five).key, :puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update smart class parameter" do
    orig_value = lookup_keys(:five).default_value
    put :update, { :id => lookup_keys(:five).to_param, :default_value => "33333" }
    assert_response :success
    new_value = lookup_keys(:five).reload.default_value
    refute_equal orig_value, new_value
  end

  test "should destroy smart class parameter" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, { :id => lookup_keys(:five).to_param }
    end
    assert_response :success
  end

  test "should return error if smart class parameter if it does not belong to specified puppetclass" do
    get :show, {:id => lookup_keys(:five).id, :puppetclass_id => puppetclasses(:one).id}
    assert_response 404
    # show_response = ActiveSupport::JSON.decode(@response.body)
    # assert !show_response.empty?
  end

end
