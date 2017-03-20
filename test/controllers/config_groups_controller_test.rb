require 'test_helper'

class ConfigGroupsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    refute_empty assigns(:config_groups)
  end

  test "should get new" do
    get :new, session: set_session_user
    assert_response :success
  end

  test "should create config_group" do
    assert_difference('ConfigGroup.count') do
      post :create, params: { :config_group => { :name => 'Custom Dev Group' } }, session: set_session_user
    end
    assert_redirected_to config_groups_path
  end

  test "should get edit" do
    get :edit, params: { :id => config_groups(:one) }, session: set_session_user
    assert_response :success
  end

  test "should update config_group" do
    put :update, params: { :id => config_groups(:one), :config_group => { :name => "new name" } }, session: set_session_user
    assert_redirected_to config_groups_path
  end

  test "should destroy config_group" do
    assert_difference('ConfigGroup.count', -1) do
      delete :destroy, params: { :id => config_groups(:three) }, session: set_session_user
    end
    assert_redirected_to config_groups_path
  end
end
