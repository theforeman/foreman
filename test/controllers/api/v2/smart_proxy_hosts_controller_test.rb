require 'test_helper'

class Api::V2::SmartProxyHostsControllerTest < ActionController::TestCase
  setup do
    @proxy = FactoryBot.create(:smart_proxy)
  end

  describe "update" do
    test "should return 422 when proxy does not exist" do
      put :update, params: { :smart_proxy_id => 12345, :id => 1 }
      assert_response :unprocessable_entity
    end

    test "should return 404 when host does not exist" do
      put :update, params: { :smart_proxy_id => @proxy.id, :id => 12345 }
      assert_response :not_found
    end

    test "should mark a host as smart proxy" do
      host = FactoryBot.create(:host)
      put :update, params: { :smart_proxy_id => @proxy.id, :id => host.id }
      assert_response :ok

      host.reload
      assert_equal host.infrastructure_facet.smart_proxy_id, @proxy.id
    end
  end

  describe "destroy" do
    test "should return 422 when proxy does not exist" do
      put :destroy, params: { :smart_proxy_id => 12345, :id => 1 }
      assert_response :unprocessable_entity
    end

    test "destroy should mark host as non-smart-proxy" do
      host = FactoryBot.create(:host, :with_infrastructure_facet)
      host.infrastructure_facet.smart_proxy_id = @proxy.id
      host.infrastructure_facet.save!

      delete :destroy, params: { :smart_proxy_id => @proxy.id, :id => host.id }
      assert_response :success
      host.reload
      assert_nil host.infrastructure_facet.smart_proxy_id
    end

    test "destroy on non-smart proxy host is a noop" do
      host = FactoryBot.create(:host)
      delete :destroy, params: { :smart_proxy_id => @proxy.id, :id => host.id }
      assert_response :not_found
      host.reload
      assert_nil host.infrastructure_facet
    end

    test "destroy on non-smart proxy, but infrastructure host is a noop" do
      host = FactoryBot.create(:host, :with_infrastructure_facet)

      delete :destroy, params: { :smart_proxy_id => @proxy.id, :id => host.id }
      assert_response :not_found
      host.reload
      assert_nil host.infrastructure_facet.smart_proxy_id
    end
  end
end
