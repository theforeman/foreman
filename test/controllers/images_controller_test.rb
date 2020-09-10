require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image      = images(:one)
    @image.uuid = Foreman.uuid.to_s
  end

  test "should get index" do
    get :index, params: { :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "should get new" do
    get :new, params: { :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    assert_response :success
  end

  test "should create image" do
    assert_difference('Image.unscoped.count') do
      image_attributes = {:name => 'gold', :username => 'ec2-user', :uuid => Foreman.uuid.to_s, :operatingsystem_id => Operatingsystem.first.id, :architecture_id => Architecture.first.id, :compute_resource_id => @image.compute_resource_id}
      post :create, params: { :image => image_attributes, :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    end

    as_admin do
      assert_redirected_to compute_resource_path(@image.compute_resource)
    end
  end

  test "should get edit" do
    get :edit, params: { :id => @image.to_param, :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    assert_response :success
  end

  test "should update image" do
    put :update, params: { :id => @image.to_param, :image => {:name => 'lala', :username => 'ec2-user'}, :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    as_admin do
      assert_redirected_to compute_resource_path(@image.compute_resource)
    end
  end

  test "should destroy image" do
    assert_difference('Image.count', -1) do
      delete :destroy, params: { :id => @image.to_param, :compute_resource_id => @image.compute_resource_id }, session: set_session_user
    end

    as_admin do
      assert_redirected_to compute_resource_path(@image.compute_resource)
    end
  end

  # listing images in /hosts/new requries a JSON response from this controller
  test "should list json images" do
    # This value is tested by the deprecation warning in application_controller
    # so we need to set it or the test will crash
    request.env['REQUEST_URI'] = "compute_resources/#{@image.compute_resource_id}/images"
    get :index, params: { :format => :json, :compute_resource_id => @image.compute_resource_id, :operatingsystem_id => @image.operatingsystem_id, :architecture_id => @image.architecture_id }, session: set_session_user
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 2, body.size
  end
end
