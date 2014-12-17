require 'test_helper'

class Api::V1::LookupKeysControllerTest < ActionController::TestCase
  valid_attrs = { :key => 'testkey', :is_param => true }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
  end

  test "should show individual record" do
    get :show, { :id => lookup_keys(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create lookup_key" do
    assert_difference('LookupKey.count') do
      post :create, { :lookup_key => valid_attrs }
    end
    assert_response :success
  end

  test "should update lookup_key" do
    #fixtures create broken lookup values, delete them. TODO: fix fixtures, or remove them
    lookup_keys(:one).lookup_values.delete_all
    put :update, { :id => lookup_keys(:one).to_param, :lookup_key => { :default_value => 8080, :lookup_values => [] } }
    assert_response :success
  end

  test "should destroy lookup_keys" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, { :id => lookup_keys(:one).to_param }
    end
    assert_response :success
  end
end
