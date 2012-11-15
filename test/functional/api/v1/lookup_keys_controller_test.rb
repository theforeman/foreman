require 'test_helper'

class Api::V1::LookupKeysControllerTest < ActionController::TestCase

  valid_attrs = { :key => 'testkey', :is_param => true }

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => lookup_keys(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create lookup_key" do
    as_user :admin do
      assert_difference('LookupKey.count') do
        post :create, {:lookup_key => valid_attrs}
      end
    end
    assert_response :success
  end

  test "should update lookup_key" do
    as_user :admin do
      put :update, {:id => lookup_keys(:one).to_param, :lookup_key => {} }
    end
    assert_response :success
  end

  test "should destroy lookup_keys" do
    as_user :admin do
      assert_difference('LookupKey.count', -1) do
        delete :destroy, {:id => lookup_keys(:one).to_param}
      end
    end
    assert_response :success
  end

end
