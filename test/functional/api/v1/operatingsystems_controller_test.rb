require 'test_helper'

class Api::V1::OperatingsystemsControllerTest < ActionController::TestCase


  os = {
    :name => "awsome_os",
    :major => "1",
    :minor => "2"
  }


  test "should get index" do
    as_user :one do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:operatingsystems)
  end

  test "should show os" do
    as_user :one do
      get :show, {:id => operatingsystems(:redhat).to_param}
    end
    assert_response :success
    assert_not_nil assigns(:operatingsystem)
  end

  test "should create os" do
    as_user :admin do
      assert_difference('Operatingsystem.count') do
        post :create, {:operatingsystem => os}
      end
    end
    assert_response :success
    assert_not_nil assigns(:operatingsystem)
  end


  test "should not create os without version" do
    as_user :admin do
      assert_difference('Operatingsystem.count', 0) do
        post :create, {:operatingsystem => os.except(:major)}
      end
    end
    assert_response :unprocessable_entity
  end

  test "should update os" do
    as_user :admin do
      put :update, {:id => operatingsystems(:redhat).to_param, :operatingsystem => {:name => "new_name"} }
    end
    assert_response :success
  end

  test "should destroy os" do
    as_user :admin do
      assert_difference('Operatingsystem.count', -1) do
        delete :destroy, {:id => operatingsystems(:no_hosts_os).to_param}
      end
    end
    assert_response :success
  end

end
