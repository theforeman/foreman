require 'test_helper'

class Api::V2::ImagesControllerTest < ActionController::TestCase
  def valid_attrs
    { :name                => 'TestImage', :username => 'ec2-user', :uuid => 'abcdef', :password => "password",
      :operatingsystem_id  => Operatingsystem.first.id,
      :compute_resource_id => ComputeResource.first.id,
      :architecture_id     => Architecture.first.id,
      :user_data           => true
    }
  end

  test "should get index" do
    get :index, params: { :compute_resource_id => images(:two).compute_resource_id }
    assert_response :success
    assert_not_nil assigns(:images)
    images = ActiveSupport::JSON.decode(@response.body)
    assert !images.empty?
  end

  test "should show individual record" do
    get :show, params: { :compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create image" do
    assert_difference('Image.count') do
      post :create, params: { :compute_resource_id => images(:two).compute_resource_id, :image => valid_attrs }
    end
    assert_response :created
  end

  test "should update image" do
    put :update, params: { :compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param, :image => { } }
    assert_response :success
  end

  test "should destroy images" do
    assert_difference('Image.count', -1) do
      delete :destroy, params: { :compute_resource_id => images(:two).compute_resource_id, :id => images(:one).to_param }
    end
    assert_response :success
  end
end
