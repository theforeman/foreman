require 'test_helper'

class ComputeProfilesControllerTest < ActionController::TestCase
  setup do
    User.current = users :admin
    @compute_profile = compute_profiles(:one)
  end

  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:compute_profiles)
  end

  test "should get new" do
    get :new, session: set_session_user
    assert_response :success
  end

  test "should create compute_profile" do
    assert_difference('ComputeProfile.count') do
      post :create, params: { :compute_profile => { :name => '10-xxlarge' } }, session: set_session_user
    end
    assert_redirected_to compute_profile_path(assigns(:compute_profile))
  end

  test "should show compute_profile" do
    get :show, params: { :id => @compute_profile }, session: set_session_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { :id => @compute_profile }, session: set_session_user
    assert_response :success
  end

  test "should update compute_profile" do
    put :update, params: { :id => @compute_profile, :compute_profile => { :name => "new name" } }, session: set_session_user
    assert_redirected_to compute_profiles_path
  end

  test "should destroy compute_profile" do
    assert_difference('ComputeProfile.count', -1) do
      delete :destroy, params: { :id => compute_profiles(:three) }, session: set_session_user
    end
    assert_redirected_to compute_profiles_path
  end
end
