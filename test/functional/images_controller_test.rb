require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image      = images(:one)
    @image.uuid = Foreman.uuid.to_s
  end

  test "should get index" do
    get :index, { :compute_resource_id => @image.compute_resource_id }, set_session_user
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "should get new" do
    get :new, { :compute_resource_id => @image.compute_resource_id }, set_session_user
    assert_response :success
  end

  test "should create image" do
    assert_difference('Image.count') do
      @image.name     = "gold"
      @image.username = "ec2-user"
      @image.uuid     = Foreman.uuid.to_s
      post :create, { :image => @image.attributes, :compute_resource_id => @image.compute_resource_id }, set_session_user
    end

    assert_redirected_to compute_resource_images_path(@image.compute_resource)
  end

  test "should show image" do
    get :show, { :id => @image.to_param, :format => "json", :compute_resource_id => @image.compute_resource_id }, set_session_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @image.to_param, :compute_resource_id => @image.compute_resource_id }, set_session_user
    assert_response :success
  end

  test "should update image" do
    @image.username = "ec2-user"
    @image.name     = "lala"
    put :update, { :id => @image.to_param, :image => @image.attributes, :compute_resource_id => @image.compute_resource_id }, set_session_user
    assert_redirected_to compute_resource_images_path(@image.compute_resource)
  end

  test "should destroy image" do
    assert_difference('Image.count', -1) do
      delete :destroy, { :id => @image.to_param, :compute_resource_id => @image.compute_resource_id }, set_session_user
    end

    assert_redirected_to compute_resource_images_path(@image.compute_resource)
  end
end
