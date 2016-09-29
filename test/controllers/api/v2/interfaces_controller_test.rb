require 'test_helper'

class Api::V2::InterfacesControllerTest < ActionController::TestCase
  valid_attrs = { 'name' => "test.foreman.com", 'ip' => "10.0.1.1", 'mac' => "AA:AA:AA:AA:AA:AA",
                  'username' => "foo", 'password' => "bar", 'provider' => "IPMI",
                  'type' => "bmc", 'ip6' => '2001:db8::1' }

  def setup
    @host = FactoryGirl.create(:host)
    @nic  = FactoryGirl.create(:nic_managed, :host => @host)
  end

  test "get index for specific host" do
    get :index, {:host_id => @host.name }
    assert_response :success
    assert_not_nil assigns(:interfaces)
    interfaces = ActiveSupport::JSON.decode(@response.body)
    assert !interfaces.empty?
  end

  test "show an interface" do
    get :show, { :host_id => @host.to_param, :id => @nic.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert "bmc", show_response["type"]
  end

  test "create interface" do
    assert_difference('@host.interfaces.count') do
      post :create, { :host_id => @host.to_param, :interface => valid_attrs }
    end
    assert_response :created
  end

  test "create interface with old style type" do
    assert_difference('@host.interfaces.count') do
      post :create, { :host_id => @host.to_param, :interface => valid_attrs.merge('type' => 'Nic::BMC') }
    end
    assert_response :created
  end

  test "create interface with unknown type" do
    post :create, { :host_id => @host.to_param, :interface => valid_attrs.merge('type' => 'UNKNOWN') }
    assert_response :unprocessable_entity
  end

  test "username and password are set on POST (create)" do
    post :create, { :host_id => @host.to_param, :interface => valid_attrs }
    assert_equal valid_attrs['password'], Nic::BMC.find_by_host_id(@host.id).password
  end

  test "update a host interface" do
    put :update, { :host_id => @host.to_param,
                   :id => @nic.to_param,
                   :interface => valid_attrs.merge({ :host_id => @host.id }) }
    assert_response :success
    assert_equal valid_attrs['ip'], Host.find_by_name(@host.name).interfaces.where(:id => @nic.to_param).first.ip
  end

  test "destroy interface" do
    assert_difference('Nic::Managed.count', -1) do
      delete :destroy, { :host_id => @host.to_param, :id => @nic.to_param }
    end
    assert_response :success
  end

  context 'permissions' do
    test 'user with permissions to view host can also view its interfaces' do
      setup_user 'view', 'hosts', "name = #{@host.name}"
      get :index, { :host_id => @host.name }, set_session_user
      assert_response :success
    end

    test 'user without permissions to view host cannot view interfaces' do
      setup_user 'view', 'hosts', "name = some.other.host"
      get :index, { :host_id => @host.name }, set_session_user
      assert_response :not_found
    end

    test 'user with hostgroup-scoped view_hosts can view its interfaces' do
      @host.update_attributes(:hostgroup => FactoryGirl.create(:hostgroup))
      setup_user 'view', 'hosts', "hostgroup_title = #{@host.hostgroup.title}"
      get :index, { :host_id => @host.name }, set_session_user
      assert_response :success
    end
  end
end
