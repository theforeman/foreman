require 'test_helper'

class Api::V1::EnvironmentsControllerTest < ActionController::TestCase

  def user_one_as_anonymous_viewer
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_one_as_manager
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Manager')]
  end

  development_environment = { :name => 'Development' }

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:environments)
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

  test "user with viewer rights should fail to update an environment" do
    user_one_as_anonymous_viewer
    as_user :one do
      put :update, {:id => environments(:production).to_param, :environment => {} }
    end
    assert_response :forbidden
  end

  test "user with manager rights should success to update an environment" do
    user_one_as_manager
    as_user :one do
      put :update, {:id => environments(:production).to_param, :environment => {} }
    end
    assert_response :success
  end

  test "user with viewer rights should succeed in viewing environments" do
    user_one_as_anonymous_viewer
    as_user :one do
      get :index, {}
    end
    assert_response :success
  end
end
