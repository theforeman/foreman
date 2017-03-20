require 'test_helper'

class Api::V1::SubnetsControllerTest < ActionController::TestCase
  valid_v4_attrs = { :name => 'QA2', :network_type => 'IPv4', :network => '10.35.2.27', :mask => '255.255.255.0' }
  valid_v6_attrs = { :name => 'QA2', :network_type => 'IPv6', :network => '2001:db8::', :mask => 'ffff:ffff:ffff:ffff::', :ipam => 'None' }

  def test_index
    get :index
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
    assert !subnets.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => subnets(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create IPv4 subnet" do
    assert_difference('Subnet::Ipv4.unscoped.count') do
      post :create, params: { :subnet => valid_v4_attrs }
    end
    assert_response :success
    assert_equal 'Subnet::Ipv4', Subnet.unscoped.find_by_name('QA2').type
  end

  test "should create IPv6 subnet" do
    assert_difference('Subnet::Ipv6.unscoped.count') do
      post :create, params: { :subnet => valid_v6_attrs }
    end
    assert_response :success
    assert_equal 'Subnet::Ipv6', Subnet.unscoped.find_by_name('QA2').type
  end

  test "does not create subnet with non-existent domain" do
    post :create, params: { :subnet => valid_v4_attrs.merge(:domain_ids => [1, 2]) }
    assert_response :not_found
  end

  test "should update subnet" do
    put :update, params: { :id => subnets(:one).to_param, :subnet => valid_v4_attrs }
    assert_response :success
  end

  test "should destroy subnets" do
    assert_difference('Subnet.unscoped.count', -1) do
      delete :destroy, params: { :id => subnets(:four).to_param }
    end
    assert_response :success
  end

  test "should NOT destroy subnet that is in use" do
    assert_difference('Subnet.unscoped.count', 0) do
      delete :destroy, params: { :id => subnets(:one).to_param }
    end
    assert_response :unprocessable_entity
  end

  def test_destroy_json
    subnet = Subnet.first
    subnet.hosts.clear
    subnet.interfaces.clear
    subnet.domains.clear
    as_admin { delete :destroy, params: { :id => subnet.id } }
    ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Subnet.exists?(:id => subnet.id)
  end
end
