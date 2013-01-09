require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_key', :value => '123' }

  test "should get index for specific host" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  test "should get index for specific domain" do
    get :index, {:domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  test "should get index for specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end


  test "should get index for specific os" do
    get :index, {:operatingsystem_id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  # test "should show parameter" do
  #   get :show, { :id => parameters(:common).to_param }
  #   assert_response :success
  #   show_response = ActiveSupport::JSON.decode(@response.body)
  #   assert !show_response.empty?
  # end

  # test "should create common_parameter" do
  #   assert_difference('CommonParameter.count') do
  #     post :create, { :common_parameter => valid_attrs }
  #   end
  #   assert_response :success
  # end

  # test "should update common_parameter" do
  #   put :update, { :id => parameters(:common).to_param, :common_parameter => { } }
  #   assert_response :success
  # end

  # test "should destroy common_parameter" do
  #   assert_difference('CommonParameter.count', -1) do
  #     delete :destroy, { :id => parameters(:common).to_param }
  #   end
  #   assert_response :success
  # end

end
