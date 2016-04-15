require 'test_helper'

class SubnetsControllerTest < ActionController::TestCase
  setup do
    @model = Subnet.first
  end

  basic_index_test
  basic_new_test
  basic_edit_test

  def test_create_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    post :create, {:subnet => {:network => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid_without_type
    post :create, {:subnet => {:network => "192.168.0.1", :cidr => "24", :name => 'testsubnet'}}, set_session_user
    assert_redirected_to subnets_url
  end

  def test_create_valid_with_type
    post :create, {:subnet => {:network => "192.168.0.1", :cidr => "24", :name => 'testsubnet', :type => 'Subnet::Ipv4'}}, set_session_user
    assert_redirected_to subnets_url
  end

  def test_update_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Subnet.first, :subnet => {:network => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Subnet.first, :subnet => {:network => '192.168.100.10'}}, set_session_user
    assert_equal '192.168.100.10', Subnet.first.network
    assert_redirected_to subnets_url
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = subnets(:one)
    delete :destroy, {:id => subnet}, set_session_user
    assert_redirected_to subnets_url
    assert Subnet.exists?(subnet.id)
  end

  def test_destroy
    subnet = Subnet.first
    subnet.hosts.clear
    subnet.interfaces.clear
    subnet.domains.clear
    delete :destroy, {:id => subnet}, set_session_user
    assert_redirected_to subnets_url
    assert !Subnet.exists?(subnet.id)
  end

  def test_freeip_fails_no_subnet
    get :freeip, {}, set_session_user

    assert_response :bad_request
  end

  def test_freeip_fails_subnet_not_authorized
    subnet_id = setup_subnet nil

    get :freeip, {subnet_id: subnet_id}, set_session_user

    assert_response :not_found
  end

  def test_freeip_not_found
    subnet = mock('subnet')
    subnet.stubs(:unused_ip).returns(nil)
    subnet_id = setup_subnet subnet

    get :freeip, {subnet_id: subnet_id}, set_session_user

    assert_response :not_found
  end

  def test_freeip_fails_on_error
    subnet = mock('subnet')
    subnet.stubs(:unused_ip).raises(StandardError, 'Exception message')
    subnet_id = setup_subnet subnet

    get :freeip, {subnet_id: subnet_id}, set_session_user

    assert_response :internal_server_error
  end

  def test_freeip_returns_json_on_success
    ip = '1.2.3.4'
    subnet = mock('subnet')
    ipam = mock()
    ipam.expects(:suggest_ip).returns(ip)
    ipam.stubs(:errors).returns({})
    subnet.stubs(:unused_ip).returns(ipam)
    subnet_id = setup_subnet subnet

    get :freeip, {subnet_id: subnet_id}, set_session_user

    assert_response :success
    assert_equal ip, JSON.parse(response.body)['ip']
    assert_empty JSON.parse(response.body)['errors']
  end

  test 'user with view_params rights should see parameters in a subnet' do
    setup_user "edit", "subnets"
    setup_user "view", "params"
    subnet = FactoryGirl.create(:subnet_ipv4, :with_parameter)
    get :edit, {:id => subnet.id}, set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Parameter']
  end

  test 'user without view_params rights should not see parameters in a subnet' do
    setup_user "edit", "subnets"
    subnet = FactoryGirl.create(:subnet_ipv4, :with_parameter)
    get :edit, {:id => subnet.id}, set_session_user.merge(:user => users(:one).id)
    assert_nil response.body['Parameter']
  end

  private

  def setup_subnet(subnet)
    subnet_id = 10
    scope = mock('scope')
    scope.expects(:find).with(subnet_id).returns(subnet)
    Subnet.stubs(:authorized).with(:view_subnets).returns(scope)
    subnet_id
  end
end
