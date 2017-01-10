require 'test_helper'

class Api::V1::RolesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'staff' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
    roles = ActiveSupport::JSON.decode(@response.body)
    assert !roles.empty?
    assert_equal Role.order(:name).pluck(:name), roles.map { |r| r['role']['name'] }
  end

  test "should show individual record" do
    get :show, { :id => roles(:manager).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create role" do
    assert_difference('Role.count') do
      post :create, { :role => valid_attrs }
    end
    assert_response :success
  end

  test "should update role" do
    put :update, { :id => roles(:destroy_hosts).to_param, :role => valid_attrs }
    assert_response :success
  end

  test "should destroy roles" do
    assert_difference('Role.count', -1) do
      delete :destroy, { :id => roles(:destroy_hosts).to_param }
    end
    assert_response :success
  end
end
