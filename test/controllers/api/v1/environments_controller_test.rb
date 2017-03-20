require 'test_helper'

class Api::V1::EnvironmentsControllerTest < ActionController::TestCase
  development_environment = { :name => 'Development' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:environments)
    envs = ActiveSupport::JSON.decode(@response.body)
    assert !envs.empty?
  end

  test "should show environment" do
    get :show, params: { :id => environments(:production).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create environment" do
    assert_difference('Environment.unscoped.count') do
      post :create, params: { :environment => development_environment }
    end
    assert_response :success
  end

  test "should update environment" do
    put :update, params: { :id => environments(:production).to_param, :environment => development_environment }
    assert_response :success
  end

  test "should destroy environments" do
    assert_difference('Environment.unscoped.count', -1) do
      delete :destroy, params: { :id => environments(:testing).to_param }
    end
    assert_response :success
  end
end
