require 'test_helper'
require 'nokogiri'

class SubnetsControllerTest < ActionController::TestCase
  setup do
    @model = subnets(:one)
    @factory_options = :with_parameter
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  context 'three similar subnets exists' do
    def setup
      as_admin do
        @s1 = FactoryBot.create(:subnet_ipv4, :network => '100.20.100.100', :cidr => '24', :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
        @s3 = FactoryBot.create(:subnet_ipv4, :network => '200.100.100.100', :cidr => '24', :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
        @s2 = FactoryBot.create(:subnet_ipv4, :network => '100.100.100.100', :cidr => '24', :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
        @s4 = FactoryBot.create(:subnet_ipv6, :network => 'beef::', :cidr => '64', :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
        @s5 = FactoryBot.create(:subnet_ipv6, :network => 'ffee::', :cidr => '64', :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
      end
    end

    def test_index_sort_by_network
      get :index, params: { :order => 'network' }, session: set_session_user
      result = assigns(:subnets).map(&:id)
      assert result.index(@s1.id) < result.index(@s2.id)
      assert result.index(@s2.id) < result.index(@s3.id)
      assert result.index(@s4.id) < result.index(@s5.id)
      assert result.index(@s1.id) < result.index(@s5.id)
    end

    def test_index_sort_by_network_desc
      get :index, params: { :order => 'network DESC' }, session: set_session_user
      result = assigns(:subnets).map(&:id)
      assert result.index(@s3.id) < result.index(@s2.id)
      assert result.index(@s2.id) < result.index(@s1.id)
      assert result.index(@s4.id) < result.index(@s1.id)
      assert result.index(@s5.id) < result.index(@s4.id)
    end
  end

  def test_create_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :subnet => {:network => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid_without_type
    post :create, params: { :subnet => {:network => "192.168.0.1", :cidr => "24", :name => 'testsubnet'} }, session: set_session_user
    assert_redirected_to subnets_url
  end

  def test_create_valid_with_type
    post :create, params: { :subnet => {:network => "192.168.0.1", :cidr => "24", :name => 'testsubnet', :type => 'Subnet::Ipv4'} }, session: set_session_user
    assert_redirected_to subnets_url
  end

  def test_update_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    subnet_id = @model
    put :update, params: { :id => subnet_id, :subnet => {:network => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @model, :subnet => {:network => '192.168.100.10'} }, session: set_session_user
    assert_equal '192.168.100.10', Subnet.unscoped.find(@model.id).network
    assert_redirected_to subnets_url
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = subnets(:one)
    delete :destroy, params: { :id => subnet }, session: set_session_user
    assert_redirected_to subnets_url
    assert Subnet.unscoped.exists?(subnet.id)
  end

  def test_destroy
    @model.hosts.clear
    @model.interfaces.clear
    @model.domains.clear
    delete :destroy, params: { :id => @model }, session: set_session_user
    assert_redirected_to subnets_url
    refute Subnet.exists?(@model.id)
  end

  context 'freeip' do
    test 'fails when subnet is not provided' do
      get :freeip, session: set_session_user
      assert_response :bad_request
    end

    test '404s when user is not authorized to see subnet' do
      subnet_id = setup_subnet
      get :freeip, params: { subnet_id: subnet_id }, session: set_session_user
      assert_response :not_found
    end

    test '404s when subnet does not have a free IP' do
      subnet = mock('subnet')
      subnet.stubs(:unused_ip).returns(nil)
      subnet_id = setup_subnet subnet

      get :freeip, params: { subnet_id: subnet_id }, session: set_session_user

      assert_response :not_found
    end

    test 'catches StandardError when fetching IP' do
      subnet = mock('subnet')
      subnet.stubs(:unused_ip).raises(StandardError, 'Exception message')
      subnet_id = setup_subnet subnet

      get :freeip, params: { subnet_id: subnet_id }, session: set_session_user

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

      get :freeip, params: { subnet_id: subnet_id }, session: set_session_user

      assert_response :success
      assert_equal ip, JSON.parse(response.body)['ip']
      assert_empty JSON.parse(response.body)['errors']
    end
  end

  context 'parameters permissions' do
    test 'with view_params user should see parameters in a subnet' do
      subnet = FactoryBot.create(:subnet_ipv4, :with_parameter)
      setup_user "edit", "subnets"
      setup_user "view", "params"
      get :edit, params: { :id => subnet.id }, session: set_session_user.merge(:user => users(:one).id)
      html_doc = Nokogiri::HTML(response.body)
      assert_not_empty html_doc.css('a[href="#params"]')
    end

    test 'without view_params user should not see parameters in a subnet' do
      subnet = FactoryBot.create(:subnet_ipv4, :with_parameter)
      setup_user "edit", "subnets"
      get :edit, params: { :id => subnet.id }, session: set_session_user.merge(:user => users(:one).id)
      html_doc = Nokogiri::HTML(response.body)
      assert_empty html_doc.css('a[href="#params"]')
    end
  end

  context 'import IPv4 subnets' do
    setup do
      SmartProxy.expects(:find).with('foo').returns(mock('proxy'))
    end

    test 'redirects to index if none were found' do
      Subnet::Ipv4.expects(:import).returns([])
      get :import, params: { :subnet_id => setup_subnet,
                             :smart_proxy_id => 'foo' }, session: set_session_user
      assert_redirected_to :subnets
      assert_match 'No new IPv4 subnets found', flash[:warning]
    end

    test 'renders import page with results' do
      Subnet::Ipv4.expects(:import).returns([FactoryBot.build_stubbed(:subnet_ipv4)])
      get :import, params: { :subnet_id => setup_subnet,
                             :smart_proxy_id => 'foo' }, session: set_session_user
      assert_response :success
      assert_template :import
      assert assigns(:subnets)
    end
  end

  test 'create_multiple filters parameters when given a list of subnets' do
    sample_subnet = FactoryBot.build_stubbed(:subnet_ipv4)
    subnet_hash = { :name => sample_subnet.name,
                    :type => sample_subnet.type,
                    :network => sample_subnet.network,
                    :mask => sample_subnet.mask,
                    :cidr => sample_subnet.cidr,
                    :ipam => sample_subnet.ipam,
                    :boot_mode => sample_subnet.boot_mode }
    assert_difference 'Subnet.unscoped.count', 1 do
      post :create_multiple, params: { :subnets => [subnet_hash] }, session: set_session_user
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
