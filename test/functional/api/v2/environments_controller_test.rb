require 'test_helper'

class Api::V2::EnvironmentsControllerTest < ActionController::TestCase
  development_environment = { :name => 'Development' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:environments)
    envs = ActiveSupport::JSON.decode(@response.body)
    assert !envs.empty?
  end

  test "should show environment" do
    get :show, { :id => environments(:production).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create environment" do
    assert_difference('Environment.count') do
      post :create, { :environment => development_environment }
    end
    assert_response :success
  end

  test "should update environment" do
    put :update, { :id => environments(:production).to_param, :environment => development_environment }
    assert_response :success
  end

  test "should destroy environments" do
    assert_difference('Environment.count', -1) do
      delete :destroy, { :id => environments(:testing).to_param }
    end
    assert_response :success
  end
end
