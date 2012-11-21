require 'test_helper'

class Api::V1::RolesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'staff' }

  test "should get index" do
    as_user :admin do
      get :index
    end
    assert_response :success
    assert_not_nil assigns(:roles)
    roles = ActiveSupport::JSON.decode(@response.body)
    assert !roles.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, { :id => roles(:manager).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create role" do
    as_user :admin do
      assert_difference('Role.count') do
        post :create, { :role => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update role" do
    as_user :admin do
      put :update, { :id => roles(:manager).to_param, :role => { } }
    end
    assert_response :success
  end

  test "should destroy roles" do
    as_user :admin do
      assert_difference('Role.count', -1) do
        delete :destroy, { :id => roles(:manager).to_param }
      end
    end
    assert_response :success
  end


end
