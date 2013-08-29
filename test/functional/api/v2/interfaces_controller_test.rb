require 'test_helper'

class Api::V2::InterfacesControllerTest < ActionController::TestCase
  valid_attrs = { 'name' => "test.foreman.com", 'ip' => "10.0.1.1", 'mac' => "AA:AA:AA:AA:AA:AA",
                  'username' => "foo", 'password' => "bar", 'provider' => "IPMI" ,
                  'type' => "Nic::BMC" }

  test "get index for specific host" do
    get :index, {:host_id => hosts(:one).name }
    assert_response :success
    assert_not_nil assigns(:interfaces)
    interfaces = ActiveSupport::JSON.decode(@response.body)
    assert !interfaces.empty?
  end

  test "show an interface" do
    get :show, { :host_id => hosts(:one).to_param, :id => nics(:bmc).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "create interface" do
    host = hosts(:one)
    assert_difference('host.interfaces.count') do
      post :create, { :host_id => host.to_param, :interface => valid_attrs }
    end
    assert_response 201
  end

  test "username and password are set on POST (create)" do
    host = hosts(:one)
    post :create, { :host_id => host.to_param, :interface => valid_attrs }
    assert_equal Nic::BMC.find_by_host_id(host.id).attrs[:password], valid_attrs['password']
  end

  test "update a host interface" do
     nics(:bmc).update_attribute(:host_id, hosts(:one).id)
     put :update, { :host_id => hosts(:one).to_param,
                    :id => nics(:bmc).to_param,
                    :interface => valid_attrs.merge( { :host_id => hosts(:one).id } ) }
     assert_response :success
     assert_equal Host.find_by_name(hosts(:one).name).interfaces.order("nics.updated_at").last.ip, valid_attrs['ip']
  end

  test "destroy interface" do
    assert_difference('Nic::BMC.count', -1) do
      delete :destroy, { :host_id => hosts(:one).to_param, :id => nics(:bmc).to_param }
    end
    assert_response :success
  end

end
