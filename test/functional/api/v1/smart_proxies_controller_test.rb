require 'test_helper'

class Api::V1::SmartProxiesControllerTest < ActionController::TestCase

  proxy_data = {
    :name => "new proxy",
    :url => "http://new.proxy.org"
  }

  test "get index" do
    as_admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:proxies)
  end

  test "get index returns valid json" do
    as_admin do
      get :index, {:format => "json"}
    end
    proxies = ActiveSupport::JSON.decode(@response.body)
    assert !proxies.empty?
    assert proxies.is_a?(Array)
    assert_response :success
  end

  test "create a smart proxy" do
    as_admin do
      post :create, {:smart_proxy => proxy_data}
    end
    assert_response :success
    assert_not_nil assigns(:smart_proxy)
  end

  test "create returns valid json" do
    as_admin do
      post :create, {:format => "json", :smart_proxy => proxy_data}
    end
    proxy = ActiveSupport::JSON.decode(@response.body)
    assert proxy.is_a? Hash
    assert proxy.symbolize_keys.key? :smart_proxy
    assert_response :success
  end

  test "update a smart proxy" do
    as_admin do
      put :update, {:id => smart_proxies(:one).to_param, :smart_proxy => {:name => "new_name"} }
    end
    assert_response :success
  end

  test "destroy a smart proxy" do
    as_admin do
      delete :destroy, {:id => smart_proxies(:unused).to_param}
    end
    assert !SmartProxy.exists?(:id => smart_proxies(:unused).to_param)
    assert_response :success
  end

end
