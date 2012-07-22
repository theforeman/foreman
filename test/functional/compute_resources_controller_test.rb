require 'test_helper'

class ComputeResourcesControllerTest < ActionController::TestCase
  setup do
    @compute_resource = compute_resources(:mycompute)
    @your_compute_resource = compute_resources(:yourcompute)
  end

  test "should not get index when not permitted" do
    setup_user "none"
    get :index, {:format => "json"}, set_session_user
    assert_response 403
  end

  test "should get index" do
    setup_user "view"
    get :index, {:format => "json"}, set_session_user
    assert_response :success
    computes = ActiveSupport::JSON.decode(@response.body)
    assert !computes.empty?
    assert computes.is_a?(Array)
    assert computes.length == 1
    assert computes.first["compute_resource"]["name"] == @compute_resource.name
  end

  test "should not get new when not permitted" do
    setup_user "view"
    get :new, {}, set_session_user
    assert_response 403
  end

  test "should get new" do
    setup_user "create"
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should not create compute resource when not permitted" do
    setup_user "view"
    assert_difference('ComputeResource.count', 0) do
      attrs = {:name => "test", :provider => "Libvirt", :url => "qemu://host/system"}
      post :create, {:compute_resource => attrs}, set_session_user
    end
    assert_response 403
  end

  test "should create compute resource" do
    setup_user "create"
    assert_difference('ComputeResource.count', +1) do
      attrs = {:name => "test", :provider => "Libvirt", :url => "qemu://host/system"}
      post :create, {:compute_resource => attrs}, set_session_user
    end

    assert_redirected_to compute_resource_url(assigns('compute_resource'))
  end

  test "should not show compute resource when not permitted" do
    setup_user "none"
    get :show, {:id => @compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should not show compute resource when restricted" do
    setup_user "view"
    get :show, {:id => @your_compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should show compute resource" do
    setup_user "view"
    get :show, {:id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should not get edit when not permitted" do
    setup_user "view"
    get :edit, {:id => @compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should not get edit when restricted" do
    setup_user "edit"
    get :edit, {:id => @your_compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should get edit" do
    setup_user "edit"
    get :edit, {:id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should not update compute resource when not permitted" do
    setup_user "view"
    put :update, {:id => @compute_resource.to_param, :compute_resource => {:name => "editing_self", :provider => "EC2"}}, set_session_user
    assert_response 403
  end

  test "should not update compute resource when restricted" do
    setup_user "edit"
    put :update, {:id => @your_compute_resource.to_param, :compute_resource => {:name => "editing_self", :provider => "EC2"}}, set_session_user
    assert_response 403
  end

  test "should update compute resource" do
    setup_user "edit"
    put :update, {:id => @compute_resource.to_param, :compute_resource => {:name => "editing_self", :provider => "EC2"}}, set_session_user
    assert_redirected_to compute_resources_path
  end

  test "should not destroy compute resource when not permitted" do
    setup_user "view"
    assert_difference('ComputeResource.count', 0) do
      delete :destroy, {:id => @compute_resource.to_param}, set_session_user
    end

    assert_response 403
  end

  test "should not destroy compute resource when restricted" do
    setup_user "destroy"
    assert_difference('ComputeResource.count', 0) do
      delete :destroy, {:id => @your_compute_resource.to_param}, set_session_user
    end

    assert_response 403
  end

  test "should destroy compute resource" do
    setup_user "destroy"
    assert_difference('ComputeResource.count', -1) do
      delete :destroy, {:id => @compute_resource.to_param}, set_session_user
    end

    assert_redirected_to compute_resources_path
  end

  def set_session_user
    User.current = users(:admin) unless User.current
    SETTINGS[:login] ? {:user => User.current.id, :expires_at => 5.minutes.from_now} : {}
  end

  def setup_user operation
    @one = users(:one)
    @request.session[:user] = @one.id
    as_admin do
      @one.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      role = Role.find_or_create_by_name :name => "#{operation}_compute_resources"
      role.permissions = ["#{operation}_compute_resources".to_sym]
      role.save!
      @one.roles << [role]
      @one.compute_resources = [@compute_resource]
      @one.save!
    end
    User.current = @one
  end
end
