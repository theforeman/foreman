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
    get :show, params: { :id => compute_profiles(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create compute profile" do
    assert_difference('ComputeProfile.count') do
      post :create, params: { :compute_profile => {:name => '4-Xlarge'} }
    end
    assert_response :created
  end

  test "should update compute_profile" do
    put :update, params: { :id => compute_profiles(:one).to_param, :compute_profile => {:name => 'new name' } }
    assert_response :success
  end

  test "should destroy compute profile" do
    assert_difference('ComputeProfile.count', -1) do
      delete :destroy, params: { :id => compute_profiles(:three).to_param }
    end
    assert_response :success
  end
end
