require 'test_helper'

class Api::V2::HostnamesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hostnames)
  end

  test "should show hostname" do
    get :show, { :id => Hostname.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid hostname" do
    post :create, { :hostname => { :name => "hostname.net", :hostname => 'hostname.net' } }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid hostname" do
    post :create, { :hostname => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should update valid hostname" do
    put :update, { :id => Hostname.unscoped.first.to_param, :hostname => { :name => "hostname.new" } }
    assert_equal "hostname.new", Hostname.unscoped.first.name
    assert_response :success
  end

  test "should not update invalid hostname" do
    put :update, { :id => Hostname.first.to_param, :hostname => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy hostname" do
    hostname = Hostname.first
    hostname.smart_proxies.clear
    delete :destroy, { :id => hostname.to_param }
    hostname = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    refute Hostname.find_by_id(hostname['id'])
  end

  #test that taxonomy scope works for api for hostnames
  def setup
    taxonomies(:location1).hostname_ids = [hostnames(:one).id, hostnames(:two).id]
    taxonomies(:organization1).hostname_ids = [hostnames(:one).id]
  end

  test "should get hostnames for location only" do
    get :index, {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal taxonomies(:location1).hostnames.length, assigns(:hostnames).length
    assert_includes assigns(:hostnames), hostnames(:one)
  end

  test "should get hostnames for organization only" do
    get :index, {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal taxonomies(:organization1).hostnames.length, assigns(:hostnames).length
    assert_includes assigns(:hostnames), hostnames(:one)
  end

  test "should get hostnames for both location and organization" do
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal (taxonomies(:location1).hostnames + taxonomies(:organization1).hostnames).uniq.length, assigns(:hostnames).length
    assert_includes assigns(:hostnames), hostnames(:one)
    taxonomies(:location1).hostname_ids = [hostnames(:two).id]
    taxonomies(:organization1).hostname_ids = []
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal (taxonomies(:location1).hostnames + taxonomies(:organization1).hostnames).uniq.length, assigns(:hostnames).length
    refute_includes assigns(:hostnames), hostnames(:one)
  end

  test "should show hostname with correct child nodes including location and organization" do
    get :show, { :id => hostnames(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert child nodes are included in response'
    NODES = ["locations", "organizations", "smart_proxies"]
    NODES.sort.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end
end
