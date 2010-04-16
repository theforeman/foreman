require 'test_helper'

class LookupKeysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:lookup_key)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create lookup_keys" do
    assert_difference('LookupKey.count') do
      post :create, {:lookup_key=>{"lookup_values_attributes"=>{"0"=>{"priority"=>"1", "value"=>"x", "_destroy"=>""},
        "1"=>{"priority"=>"2", "value"=>"y", "_destroy"=>""}},
        "key"=>"tests"}
      },
        set_session_user
    end

    assert_redirected_to lookup_keys_path(assigns(:lookup_keys))
  end

  test "should get edit" do
    get :edit, {:id => lookup_keys(:one).to_param}, set_session_user
    assert_response :success
  end

  test "should update lookup_keys" do
    put :update, {:id => lookup_keys(:one).to_param, :lookup_key => { :key => "test that" }}, set_session_user
    assert_redirected_to lookup_keys_path(assigns(:lookup_keys))
  end

  test "should destroy lookup_keys" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, {:id => lookup_keys(:one).to_param}, set_session_user
    end

    assert_redirected_to lookup_keys_path
  end
end
