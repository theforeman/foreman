require 'test_helper'

class AuthSourcesControllerTest < ActionController::TestCase
=begin
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:auth_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create auth_source" do
    assert_difference('AuthSource.count') do
      post :create, :auth_source => { }
    end

    assert_redirected_to auth_source_path(assigns(:auth_source))
  end

  test "should show auth_source" do
    get :show, :id => auth_sources(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => auth_sources(:one).to_param
    assert_response :success
  end

  test "should update auth_source" do
    put :update, :id => auth_sources(:one).to_param, :auth_source => { }
    assert_redirected_to auth_source_path(assigns(:auth_source))
  end

  test "should destroy auth_source" do
    assert_difference('AuthSource.count', -1) do
      delete :destroy, :id => auth_sources(:one).to_param
    end

    assert_redirected_to auth_sources_path
  end
=end
end
