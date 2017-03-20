require 'test_helper'

class Api::V2::RealmsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:realms)
  end

  test "should show realm" do
    get :show, params: { :id => Realm.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid realm" do
    post :create, params: { :realm => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should create valid realm" do
    post :create, params: { :realm => { :name => "realm.net", :realm_proxy_id => smart_proxies(:realm).to_param, :realm_type => "FreeIPA" } }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update valid realm" do
    realm_id = Realm.unscoped.first.id
    put :update, params: { :id => realm_id, :realm => { :name => "realm.new" } }
    assert_equal "realm.new", Realm.unscoped.find(realm_id).name
    assert_response :success
  end

  test "should not update invalid realm" do
    put :update, params: { :id => Realm.first.to_param, :realm => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy realm" do
    realm = Realm.first
    realm.hosts.clear
    realm.hostgroups.clear
    delete :destroy, params: { :id => realm.to_param }
    realm = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    refute Realm.unscoped.find_by_id(realm['id'])
  end

  #test that taxonomy scope works for api for realms
  def setup
    taxonomies(:location1).realm_ids = [realms(:myrealm).id, realms(:yourrealm).id]
    taxonomies(:organization1).realm_ids = [realms(:myrealm).id]
  end

  test "should get realms for location only" do
    get :index, params: { :location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal taxonomies(:location1).realms.length, assigns(:realms).length
    assert_equal assigns(:realms), taxonomies(:location1).realms
  end

  test "should get realms for organization only" do
    get :index, params: { :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal taxonomies(:organization1).realms.length, assigns(:realms).length
    assert_equal assigns(:realms), taxonomies(:organization1).realms
  end

  test "should get realms for both location and organization" do
    get :index, params: { :location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:realms).length
    assert_equal assigns(:realms), [realms(:myrealm)]
  end

  test "should show realm with correct child nodes including location and organization" do
    get :show, params: { :id => realms(:myrealm).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert child nodes are included in response'
    NODES = ["locations", "organizations"]
    NODES.sort.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end
end
