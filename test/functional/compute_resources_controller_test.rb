require 'test_helper'

class ComputeResourcesControllerTest < ActionController::TestCase
  setup do
    @compute_resource = compute_resources(:one)
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:compute_resources)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create compute_resource" do
    assert_difference('ComputeResource.count') do
      attrs = {:name => "test", :provider => "Libvirt", :url => "qemu://host/system"}
      post :create, {:compute_resource => attrs}, set_session_user
    end

    assert_redirected_to compute_resources_path
  end

  test "should show compute_resource" do
    get :show, {:id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, {:id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should update compute_resource" do
    put :update, {:id => @compute_resource.to_param, :compute_resource => {:name => "editing_self", :provider => "EC2"}}, set_session_user
    assert_redirected_to compute_resources_path
  end

  test "should destroy compute_resource" do
    assert_difference('ComputeResource.count', -1) do
      delete :destroy, {:id => @compute_resource.to_param}, set_session_user
    end

    assert_redirected_to compute_resources_path
  end
end
