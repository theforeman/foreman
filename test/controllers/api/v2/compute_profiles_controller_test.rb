require 'test_helper'

class Api::V2::ComputeProfilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compute_profiles)
    compute_profiles = ActiveSupport::JSON.decode(@response.body)
    assert !compute_profiles.empty?
  end

  test "should show individual record" do
    Foreman::Model::EC2.any_instance.expects(:normalize_vm_attrs).returns({})
    get :show, params: { :id => compute_profiles(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test_attributes :pid => '97d04911-9368-4674-92c7-1e3ff114bc18'
  test "should create compute profile" do
    name = '4-Xlarge'
    assert_difference('ComputeProfile.count') do
      post :create, params: { :compute_profile => {:name => name} }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['name'], name, "Can't create compute profile with valid name #{name}"
  end

  test_attributes :pid => '2d34a1fd-70a5-4e59-b2e2-86fbfe8e31ab'
  test "should not create compute profile" do
    assert_difference('ComputeProfile.count', 0) do
      post :create, params: { :compute_profile => {:name => ''} }
    end
    assert_response :unprocessable_entity
    assert_match "Name can't be blank", @response.body
  end

  test_attributes :pid => 'c79193d7-2e0f-4ed9-b947-05feeddabfda'
  test "should update compute_profile" do
    Foreman::Model::EC2.any_instance.expects(:normalize_vm_attrs).returns({})
    name = 'new name'
    put :update, params: { :id => compute_profiles(:one).to_param, :compute_profile => {:name => name } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['name'], name, "Can't update compute profile with valid name #{name}"
  end

  test_attributes :pid => '042b40d5-a78b-4e65-b5cb-5b270b800b37'
  test "should not update compute_profile" do
    put :update, params: { :id => compute_profiles(:one).to_param, :compute_profile => {:name => '' } }
    assert_response :unprocessable_entity
    assert_match "Name can't be blank", @response.body
  end

  test_attributes :pid => '0a620e23-7ba6-4178-af7a-fd1e332f478f'
  test "should destroy compute profile" do
    assert_difference('ComputeProfile.count', -1) do
      delete :destroy, params: { :id => compute_profiles(:three).to_param }
    end
    assert_response :success
  end
end
