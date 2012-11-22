require 'test_helper'

class Api::V1::SmartProxiesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'master02', :url => 'http://server:8443' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    assert !smart_proxies.empty?
  end

  test "should show individual record" do
    get :show, { :id => smart_proxies(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create smart_proxy" do
    assert_difference('SmartProxy.count') do
      post :create, { :smart_proxy => valid_attrs }
    end
    assert_response :success
  end

  test "should update smart_proxy" do
    put :update, { :id => smart_proxies(:one).to_param, :smart_proxy => { } }
    assert_response :success
  end

  test "should destroy smart_proxy" do
    assert_difference('SmartProxy.count', -1) do
        delete :destroy, { :id => smart_proxies(:four).to_param }
    end
    assert_response :success
  end

  # Pending - failure on .permission_failed?
  # test "should not destroy smart_proxy that is in use" do
  #   as_user :admin do
  #     assert_difference('SmartProxy.count', 0) do
  #       delete :destroy, {:id => smart_proxies(:one).to_param}
  #     end
  #   end
  #   assert_response :unprocessable_entity
  # end

end
