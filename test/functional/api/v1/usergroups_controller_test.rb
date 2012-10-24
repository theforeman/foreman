require 'test_helper'

class Api::V1::UsergroupsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_usergroup' }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:usergroups)
    usergroups = ActiveSupport::JSON.decode(@response.body)
    assert !usergroups.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, { :id => usergroups(:one).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create usergroup" do
    as_user :admin do
      assert_difference('Usergroup.count') do
        post :create, { :usergroup => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update usergroup" do
    as_user :admin do
      put :update, { :id => usergroups(:one).to_param, :usergroup => { } }
    end
    assert_response :success
  end

  test "should destroy usergroups" do
    as_user :admin do
      assert_difference('Usergroup.count', -1) do
        delete :destroy, { :id => usergroups(:one).to_param }
      end
    end
    assert_response :success
  end


end
