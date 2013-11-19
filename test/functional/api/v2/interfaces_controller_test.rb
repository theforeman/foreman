require 'test_helper'

class Api::V2::InterfacesControllerTest < ActionController::TestCase
  valid_attrs = { 'name' => "test.foreman.com", 'ip' => "10.0.1.1", 'mac' => "AA:AA:AA:AA:AA:AA",
                  'username' => "foo", 'password' => "bar", 'provider' => "IPMI" ,
                  'type' => "Nic::BMC" }

  test "get index for specific system" do
    get :index, {:system_id => systems(:one).name }
    assert_response :success
    assert_not_nil assigns(:interfaces)
    interfaces = ActiveSupport::JSON.decode(@response.body)
    assert !interfaces.empty?
  end

  test "show an interface" do
    get :show, { :system_id => systems(:one).to_param, :id => nics(:bmc).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "create interface" do
    system = systems(:one)
    assert_difference('system.interfaces.count') do
      post :create, { :system_id => system.to_param, :interface => valid_attrs }
    end
    assert_response 201
  end

  test "username and password are set on POST (create)" do
    system = systems(:one)
    post :create, { :system_id => system.to_param, :interface => valid_attrs }
    assert_equal Nic::BMC.find_by_system_id(system.id).attrs[:password], valid_attrs['password']
  end

  test "update a system interface" do
     nics(:bmc).update_attribute(:system_id, systems(:one).id)
     put :update, { :system_id => systems(:one).to_param,
                    :id => nics(:bmc).to_param,
                    :interface => valid_attrs.merge( { :system_id => systems(:one).id } ) }
     assert_response :success
     assert_equal System.find_by_name(systems(:one).name).interfaces.order("nics.updated_at").last.ip, valid_attrs['ip']
  end

  test "destroy interface" do
    assert_difference('Nic::BMC.count', -1) do
      delete :destroy, { :system_id => systems(:one).to_param, :id => nics(:bmc).to_param }
    end
    assert_response :success
  end

end
