require 'test_helper'

class Api::V2::RealmsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:realms)
  end

  test "should show realm" do
    get :show, { :id => Realm.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid realm" do
    post :create, { :name => "realm.net", :realm_proxy_id => smart_proxies(:realm).to_param, :realm_type => "FreeIPA" }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid realm" do
    post :create, { :name => "" }
    assert_response :unprocessable_entity
  end

  test "should update valid realm" do
    put :update, { :id => Realm.first.to_param, :name => "realm.new" }
    assert_equal "realm.new", Realm.first.name
    assert_response :success
  end

  test "should not update invalid realm" do
    put :update, { :id => Realm.first.to_param, :name => ""  }
    assert_response :unprocessable_entity
  end

  test "should destroy realm" do
    realm = Realm.first
    realm.hosts.clear
    realm.hostgroups.clear
    delete :destroy, { :id => realm.to_param }
    realm = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    refute Realm.find_by_id(realm['id'])
  end

  #test that taxonomy scope works for api for realms
  def setup
    taxonomies(:location1).realm_ids = [realms(:myrealm).id, realms(:yourrealm).id]
    taxonomies(:organization1).realm_ids = [realms(:myrealm).id]
  end

  test "should get realms for location only" do
    get :index, {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal 2, assigns(:realms).length
    assert_equal assigns(:realms), [realms(:myrealm), realms(:yourrealm)]
  end

  test "should get realms for organization only" do
    get :index, {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:realms).length
    assert_equal assigns(:realms), [realms(:myrealm)]
  end

  test "should get realms for both location and organization" do
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:realms).length
    assert_equal assigns(:realms), [realms(:myrealm)]
  end

  test "should show realm with correct child nodes including location and organization" do
    get :show, { :id => realms(:myrealm).to_param }
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
