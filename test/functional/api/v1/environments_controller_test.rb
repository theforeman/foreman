require 'test_helper'

class Api::V1::EnvironmentsControllerTest < ActionController::TestCase

  development_environment = { :name => 'Development' }

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:environments)
    envs = ActiveSupport::JSON.decode(@response.body)
    assert !envs.empty?
  end

  test "should show environment" do
    as_user :admin do
      get :show, {:id => environments(:production).to_param}
    end
    assert_response :success
  end

  test "should create environment" do
    as_user :admin do
      assert_difference('Environment.count') do
        post :create, {:environment => development_environment}
      end
    end
    assert_response :success
  end

  test "should update environment" do
    as_user :admin do
      put :update, {:id => environments(:production).to_param, :environment => {} }
    end
    assert_response :success
  end

  test "should destroy environments" do
    as_user :admin do
      assert_difference('Environment.count', -1) do
        delete :destroy, {:id => environments(:testing).to_param}
      end
    end
    assert_response :success
  end
end
