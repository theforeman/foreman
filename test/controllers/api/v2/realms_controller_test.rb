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

  test "should not create realm with no proxy" do
    post :create, params: { :realm => { :name => 'realm.net', :realm_proxy_id => 0, :realm_type => 'FreeIPA' }}
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

  context 'taxonomy scope' do
    let (:myrealm) { realms(:myrealm) }
    let (:yourrealm) { realms(:yourrealm) }
    let (:loc) { FactoryBot.create(:location, realms: [myrealm, yourrealm]) }
    let (:org) { FactoryBot.create(:organization, realms: [myrealm]) }

    test "should get realms for location only" do
      get :index, params: { :location_id => loc.id }
      assert_response :success
      assert_equal loc.realms.length, assigns(:realms).length
      assert_equal assigns(:realms).sort, loc.realms.sort
    end

    test "should get realms for organization only" do
      get :index, params: { :organization_id => org.id }
      assert_response :success
      assert_equal org.realms.length, assigns(:realms).length
      assert_equal assigns(:realms), org.realms
    end

    test "should get realms for both location and organization" do
      get :index, params: { :location_id => loc.id, :organization_id => org.id }
      assert_response :success
      assert_equal 1, assigns(:realms).length
      assert_equal assigns(:realms), [myrealm]
    end

    test "should show realm with correct child nodes including location and organization" do
      get :show, params: { :id => myrealm.to_param }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert !show_response.empty?

      ["locations", "organizations"].each do |node|
        assert show_response.key?(node), "'#{node}' child node should be in response but was not"
      end
    end
  end
end
