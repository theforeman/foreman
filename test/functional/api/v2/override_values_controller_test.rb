require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase

  smart_variable_attrs = { :match => 'xyz=10', :value => 'string' }
  smart_class_attrs = { :match => 'host=abc.com', :value => 'liftoff' }

  test "should get override values for specific smart variable" do
    get :index, {:smart_variable_id => lookup_keys(:two).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert !override_values.empty?
    assert_equal 1, override_values["results"].length
  end
  test "should get override values for specific smart class parameter" do
    get :index, {:smart_class_parameter_id => lookup_keys(:complex).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert !override_values.empty?
    assert_equal 2, override_values["results"].length
  end

  test "should create override values for specific smart variable" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_variable_id => lookup_keys(:four).to_param, :override_value => smart_variable_attrs }
    end
    assert_response :success
  end
  test "should create override values for specific smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :success
  end

  test "should show specific override values for specific smart variable" do
    get :show,  {:smart_variable_id => lookup_keys(:two).to_param, :id => lookup_values(:four).to_param }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['override_value'].empty?
    assert_equal "hostgroup=Common", results['override_value']['match']
  end
  test "should show specific override values for specific smart class parameter" do
    get :show,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param }
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['override_value'].empty?
    assert_equal "hostgroup=Common", results['override_value']['match']
    assert_response :success
  end

  test "should update specific override value" do
    put :update, { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'host=abc.com' } }
    assert_response :success
  end

  test "should destroy specific override value" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'host=abc.com' } }
    end
    assert_response :success
  end

end