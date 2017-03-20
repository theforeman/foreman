require 'test_helper'

class Api::V1::OperatingsystemsControllerTest < ActionController::TestCase
  os = {
    :name  => "awsome_os",
    :major => "1",
    :minor => "2"
  }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operatingsystems)
  end

  test "should show os" do
    get :show, params: { :id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:operatingsystem)
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create os" do
    assert_difference('Operatingsystem.count') do
      post :create, params: { :operatingsystem => os }
    end
    assert_response :success
    assert_not_nil assigns(:operatingsystem)
  end

  test "should not create os without version" do
    assert_difference('Operatingsystem.count', 0) do
      post :create, params: { :operatingsystem => os.except(:major) }
    end
    assert_response :unprocessable_entity
  end

  test "should update os" do
    put :update, params: { :id => operatingsystems(:redhat).to_param, :operatingsystem => { :name => "new_name" } }
    assert_response :success
  end

  test "should destroy os" do
    assert_difference('Operatingsystem.count', -1) do
      delete :destroy, params: { :id => operatingsystems(:no_hosts_os).to_param }
    end
    assert_response :success
  end
end
