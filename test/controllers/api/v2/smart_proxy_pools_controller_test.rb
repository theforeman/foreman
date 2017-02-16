require 'test_helper'

class Api::V2::SmartProxyPoolsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_proxy_pools)
  end

  test "should show smart_proxy_pools" do
    get :show, params: { :id => SmartProxyPool.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid smart_proxy_pool" do
    post :create, params: { :smart_proxy_pool => { :name => "my pool", :hostname => 'hostname.net' } }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid smart_proxy_pool" do
    post :create, params: { :smart_proxy_pool => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should update valid smart_proxy_pools" do
    put :update, params: { :id => SmartProxyPool.unscoped.first.to_param, :smart_proxy_pool => { :name => "hostname.new" } }
    assert_equal "hostname.new", SmartProxyPool.unscoped.first.name
    assert_response :success
  end

  test "should not update invalid smart_proxy_pool" do
    put :update, params: { :id => SmartProxyPool.first.to_param, :smart_proxy_pool => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy smart_proxy_pool" do
    smart_proxy_pool = SmartProxyPool.first
    smart_proxy_pool.smart_proxies.clear
    delete :destroy, params: { :id => smart_proxy_pool.to_param }
    smart_proxy_pool = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    refute SmartProxyPool.find_by_id(smart_proxy_pool['id'])
  end

  # test that taxonomy scope works with api for smart_proxy_pools
  def setup
    taxonomies(:location1).smart_proxy_pool_ids = [smart_proxy_pools(:one).id, smart_proxy_pools(:two).id]
    taxonomies(:organization1).smart_proxy_pool_ids = [smart_proxy_pools(:one).id]
  end

  test "should get smart_proxy_pools for location only" do
    get :index, params: {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal taxonomies(:location1).smart_proxy_pools.length, assigns(:smart_proxy_pools).length
    assert_includes assigns(:smart_proxy_pools), smart_proxy_pools(:one)
  end

  test "should get smart_proxy_pools for organization only" do
    get :index, params: {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal taxonomies(:organization1).smart_proxy_pools.length, assigns(:smart_proxy_pools).length
    assert_includes assigns(:smart_proxy_pools), smart_proxy_pools(:one)
  end

  test "should get smart_proxy_pools for both location and organization" do
    get :index, params: {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal (taxonomies(:location1).smart_proxy_pools + taxonomies(:organization1).smart_proxy_pools).uniq.length, assigns(:smart_proxy_pools).length
    assert_includes assigns(:smart_proxy_pools), smart_proxy_pools(:one)
    taxonomies(:location1).smart_proxy_pool_ids = [smart_proxy_pools(:two).id]
    taxonomies(:organization1).smart_proxy_pool_ids = []
    get :index, params: {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal (taxonomies(:location1).smart_proxy_pools + taxonomies(:organization1).smart_proxy_pools).uniq.length, assigns(:smart_proxy_pools).length
    refute_includes assigns(:smart_proxy_pools), smart_proxy_pools(:one)
  end

  test "should show smart_proxy_pool with correct child nodes including location and organization" do
    get :show, params: { :id => smart_proxy_pools(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    # assert child nodes are included in response'
    NODES = ["locations", "organizations", "smart_proxies"]
    NODES.sort.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end
end
