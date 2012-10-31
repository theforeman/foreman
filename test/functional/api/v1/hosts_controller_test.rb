require 'test_helper'

class Api::V1::HostsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'Bighost', :environment_id => Environment.first.id }

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => hosts(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create host" do
    as_user :admin do
      assert_difference('Host.count') do
        post :create, {:host => valid_attrs}
      end
    end
    assert_response :success
  end

  test "should update host" do
    as_user :admin do
      put :update, {:id => hosts(:one).to_param, :host => {} }
    end
    assert_response :success
  end

  test "should destroy hosts" do
    as_user :admin do
      assert_difference('Host.count', -1) do
        delete :destroy, {:id => hosts(:one).to_param}
      end
    end
    assert_response :success
  end

end
