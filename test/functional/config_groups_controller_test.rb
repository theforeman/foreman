require 'test_helper'

class ConfigGroupsControllerTest < ActionController::TestCase
  setup do
    User.current = User.admin
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    refute_empty assigns(:config_groups)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create config_group" do
    assert_difference('ConfigGroup.count') do
      post :create, {:config_group => { :name => 'Custom Dev Group' }}, set_session_user
    end
    assert_redirected_to config_groups_path
  end

  test "should get edit" do
    get :edit, {:id => config_groups(:one)}, set_session_user
    assert_response :success
  end

  test "should update config_group" do
    put :update, {:id => config_groups(:one), :config_group => { :name => "new name" }}, set_session_user
    assert_redirected_to config_groups_path
  end

  test "should destroy config_group" do
    assert_difference('ConfigGroup.count', -1) do
      delete :destroy, {:id => config_groups(:three)}, set_session_user
    end
    assert_redirected_to config_groups_path
  end
end
