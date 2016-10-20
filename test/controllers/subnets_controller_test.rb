require 'test_helper'

class SubnetsControllerTest < ActionController::TestCase
  setup do
    @model = subnets(:one)
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
    # Find a way to raise the point where User.current changes
    Subnet.any_instance.stubs(:valid?).returns(false)
    subnet_id = @model
    put :update, {:id => subnet_id, :subnet => {:network => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => @model, :subnet => {:network => '192.168.100.10'}}, set_session_user
    assert_equal '192.168.100.10', Subnet.unscoped.find(@model).network
    assert_redirected_to subnets_url
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = subnets(:one)
    delete :destroy, {:id => subnet}, set_session_user
    assert_redirected_to subnets_url
    assert Subnet.unscoped.exists?(subnet.id)
  end

  def test_destroy
    @model.hosts.clear
    @model.interfaces.clear
    @model.domains.clear
    delete :destroy, {:id => @model}, set_session_user
    assert_redirected_to subnets_url
    refute Subnet.exists?(@model.id)
  end

  context 'freeip' do
    test 'fails when subnet is not provided' do
      get :freeip, {}, set_session_user
      assert_response :bad_request
    end

    test '404s when user is not authorized to see subnet' do
      subnet_id = setup_subnet
      get :freeip, {subnet_id: subnet_id}, set_session_user
      assert_response :not_found
    end

    test '404s when subnet does not have a free IP' do
      subnet = mock('subnet')
      subnet.stubs(:unused_ip).returns(nil)
      subnet_id = setup_subnet subnet

      get :freeip, {subnet_id: subnet_id}, set_session_user

      assert_response :not_found
    end

    test 'catches StandardError when fetching IP' do
      subnet = mock('subnet')
      subnet.stubs(:unused_ip).raises(StandardError, 'Exception message')
      subnet_id = setup_subnet subnet

      get :freeip, {subnet_id: subnet_id}, set_session_user

      assert_response :internal_server_error
    end

    test 'returns JSON on success' do
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
  end

  context 'parameters permissions' do
    test 'with view_params user should see parameters in a subnet' do
      setup_user "edit", "subnets"
      setup_user "view", "params"
      subnet = FactoryGirl.create(:subnet_ipv4, :with_parameter)
      get :edit, {:id => subnet.id}, set_session_user.merge(:user => users(:one).id)
      assert_not_nil response.body['Parameter']
    end

    test 'without view_params user should not see parameters in a subnet' do
      setup_user "edit", "subnets"
      subnet = FactoryGirl.create(:subnet_ipv4, :with_parameter)
      get :edit, {:id => subnet.id}, set_session_user.merge(:user => users(:one).id)
      assert_nil response.body['Parameter']
    end
  end

  context 'import IPv4 subnets' do
    setup do
      SmartProxy.expects(:find).with('foo').returns(mock('proxy'))
    end

    test 'redirects to index if none were found' do
      Subnet::Ipv4.expects(:import).returns([])
      get :import, { :subnet_id => setup_subnet,
                     :smart_proxy_id => 'foo' }, set_session_user
      assert_redirected_to :subnets
      assert_match 'No new IPv4 subnets found', flash[:warning]
    end

    test 'renders import page with results' do
      Subnet::Ipv4.expects(:import).returns([FactoryGirl.build(:subnet_ipv4)])
      get :import, { :subnet_id => setup_subnet,
                     :smart_proxy_id => 'foo' }, set_session_user
      assert_response :success
      assert_template :import
      assert assigns(:subnets)
    end
  end

  test 'create_multiple filters parameters when given a list of subnets' do
    sample_subnet = FactoryGirl.build(:subnet_ipv4)
    subnet_hash = { :name => sample_subnet.name,
                    :type => sample_subnet.type,
                    :network => sample_subnet.network,
                    :mask => sample_subnet.mask,
                    :cidr => sample_subnet.cidr,
                    :ipam => sample_subnet.ipam,
                    :boot_mode => sample_subnet.boot_mode }
    assert_difference 'Subnet.unscoped.count', 1 do
      post :create_multiple, { :subnets => [subnet_hash] }, set_session_user
    end
    assert_response :redirect
    assert_redirected_to subnets_url
  end

  private

  def setup_subnet(subnet = nil)
    subnet_id = 10
    scope = mock('scope')
    scope.stubs(:find).with(subnet_id).returns(subnet)
    Subnet.stubs(:authorized).with(:view_subnets).returns(scope)
    subnet_id
  end
end
