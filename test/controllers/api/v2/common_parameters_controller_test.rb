require 'test_helper'

class Api::V2::CommonParametersControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'special_key', :default_value => '123' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:common_parameters)
    common_parameters = ActiveSupport::JSON.decode(@response.body)
    assert !common_parameters.empty?
  end

  test "should show parameter" do
    get :show, { :id => lookup_keys(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create common_parameter" do
    assert_difference('GlobalLookupKey.all.count') do
      post :create, { :common_parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should update common_parameter" do
    put :update, { :id => lookup_keys(:common).to_param, :common_parameter => valid_attrs }
    assert_response :success
  end

  test "should destroy common_parameter" do
    assert_difference('GlobalLookupKey.all.count', -1) do
      delete :destroy, { :id => lookup_keys(:common).to_param }
    end
    assert_response :success
  end
end
