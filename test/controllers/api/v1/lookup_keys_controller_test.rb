require 'test_helper'

class Api::V1::LookupKeysControllerTest < ActionController::TestCase
  valid_attrs = { :key => 'testkey' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => lookup_keys(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create lookup_key" do
    assert_difference('LookupKey.count') do
      post :create, params: { :lookup_key => valid_attrs }
    end
    assert_response :success
  end

  test "should update lookup_key" do
    put :update, params: { :id => lookup_keys(:one).to_param, :lookup_key => { :default_value => 8080, :lookup_values => [], :override => true } }
    assert_response :success
  end

  test "should not destroy PuppetclassLookupKey" do
    assert_difference('LookupKey.count', 0) do
      delete :destroy, params: { :id => lookup_keys(:one).to_param }
    end
    assert_response :unprocessable_entity
    assert_match 'Smart class parameters cannot be destroyed', @response.body
  end

  test "should destroy VariableLookupKey" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, params: { :id => lookup_keys(:two).to_param }
    end
    assert_response :success
  end
end
