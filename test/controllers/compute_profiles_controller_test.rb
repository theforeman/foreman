require 'test_helper'

class ComputeProfilesControllerTest < ActionController::TestCase
  setup do
    User.current = users :admin
    @compute_profile = compute_profiles(:one)
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:compute_profiles)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create compute_profile" do
    assert_difference('ComputeProfile.count') do
      post :create, {:compute_profile => { :name => '10-xxlarge' }}, set_session_user
    end
    assert_redirected_to compute_profile_path(assigns(:compute_profile))
  end

  test "should show compute_profile" do
    get :show, {:id => @compute_profile}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, {:id => @compute_profile}, set_session_user
    assert_response :success
  end

  test "should update compute_profile" do
    put :update, {:id => @compute_profile, :compute_profile => { :name => "new name" }}, set_session_user
    assert_redirected_to compute_profiles_path
  end

  test "should destroy compute_profile" do
    assert_difference('ComputeProfile.count', -1) do
      delete :destroy, {:id => compute_profiles(:three)}, set_session_user
    end
    assert_redirected_to compute_profiles_path
  end
end
