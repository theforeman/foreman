require 'test_helper'

class Api::V1::HostgroupsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'TestHostgroup' }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:hostgroups)
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, { :id => hostgroups(:common).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create hostgroup" do
    as_user :admin do
      assert_difference('Hostgroup.count') do
        post :create, { :hostgroup => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update hostgroup" do
    as_user :admin do
      put :update, { :id => hostgroups(:common).to_param, :hostgroup => { } }
    end
    assert_response :success
  end

  test "should destroy hostgroups" do
    as_user :admin do
      assert_difference('Hostgroup.count', -1) do
        delete :destroy, { :id => hostgroups(:common).to_param }
      end
    end
    assert_response :success
  end

end
