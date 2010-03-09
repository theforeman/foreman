require 'test_helper'

class LookupKeysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lookup_keys" do
    assert_difference('LookupKeys.count') do
      post :create, :lookup_keys => { }
    end

    assert_redirected_to lookup_keys_path(assigns(:lookup_keys))
  end

  test "should show lookup_keys" do
    get :show, :id => lookup_keys(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => lookup_keys(:one).to_param
    assert_response :success
  end

  test "should update lookup_keys" do
    put :update, :id => lookup_keys(:one).to_param, :lookup_keys => { }
    assert_redirected_to lookup_keys_path(assigns(:lookup_keys))
  end

  test "should destroy lookup_keys" do
    assert_difference('LookupKeys.count', -1) do
      delete :destroy, :id => lookup_keys(:one).to_param
    end

    assert_redirected_to lookup_keys_path
  end
end
