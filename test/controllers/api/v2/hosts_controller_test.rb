require 'test_helper'
require 'controllers/shared/pxe_loader_test'

class Api::V2::HostsControllerTest < ActionController::TestCase
  include ::PxeLoaderTest
  include FactImporterIsolation

  allow_transactions_for_any_importer

  def setup
    as_admin do
      @host = FactoryBot.create(:host)
      @ptable = FactoryBot.create(:ptable)
      @ptable.operatingsystems = [Operatingsystem.find_by_name('Redhat')]
      Host::Managed.any_instance.stubs(:vm_exists?).returns(true)
    end
  end

  def basic_attrs
    { :name                => 'testhost11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ptable_id           => @ptable.id,
      :medium_id           => media(:one).id,
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:puppetmaster).id,
      :compute_resource_id => compute_resources(:one).id,
      :compute_attributes => {
        :cpus => 4,
        :memory => 1024,
      },
      :root_pass           => "xybxa6JUkz63w",
      :location_id         => taxonomies(:location1).id,
      :organization_id     => taxonomies(:organization1).id,
    }
  end

  def valid_attrs
    net_attrs = {
      :ip => '10.0.0.20',
    }
    basic_attrs.merge(net_attrs)
  end

  def valid_attrs_with_root(extra_attrs = {})
    { :host => valid_attrs.merge(extra_attrs) }
  end

  def basic_attrs_with_profile(compute_attrs)
    basic_attrs.merge(
      :compute_resource_id => compute_attrs.compute_resource_id,
      :compute_profile_id => compute_attrs.compute_profile_id
    )
  end

  def basic_attrs_with_hg
    hostgroup_attr = {
      :hostgroup_id => Hostgroup.first.id,
    }
    basic_attrs.merge(hostgroup_attr)
  end

  def nics_attrs
    [{
      :primary => true,
      :ip => '10.0.0.20',
    }, {
      :type => 'bmc',
      :provider => 'IPMI',
      :mac => '00:11:22:33:44:01',
      :subnet_id => subnets(:one).id,
    }, {
      :mac => '00:11:22:33:44:02',
      :_destroy => 1,
    }]
  end

  def expected_compute_attributes(compute_attrs, index)
    compute_attrs.vm_interfaces[index].update("from_profile" => compute_attrs.compute_profile.name)
  end

  def expect_attribute_modifier(modifier_class, args)
    modifier = mock(modifier_class.name)
    modifier_class.expects(:new).with(*args).returns(modifier)
    Host.any_instance.expects(:apply_compute_profile).with(modifier)
  end

  def last_record
    Host.unscoped.order(:id).last
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
  end

  test "should get thin index" do
    get :index, params: { thin: true }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
    assert_equal Host.all.pluck(:id, :name), hosts['results'].map(&:values)
  end

  test "subtotal should be the same as the search count with thin" do
    FactoryBot.create_list(:host, 2)
    Host.last.update_attribute(:name, 'test')

    get :index, params: { thin: true, per_page: 1, search: 'host' }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_equal hosts['subtotal'], Host.search_for('host').size
  end

  test "should include registered scope on index" do
    # remember the previous state
    old_scopes = Api::V2::HostsController.scopes_for(:index).dup

    scope_accessed = false
    Api::V2::HostsController.add_scope_for(:index) do |base_scope|
      scope_accessed = true
      base_scope
    end
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?

    # restore the previous state
    new_scopes = Api::V2::HostsController.scopes_for(:index)
    new_scopes.keep_if { |s| old_scopes.include?(s) }
  end

  test "should get attributes in ordered index" do
    last_record.update(ip: "127.13.0.1")
    get :index, params: { order: "mac" }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    ip_addresses = hosts["results"].map { |host| host["ip"] }
    refute ip_addresses.empty?
    assert_includes(ip_addresses, "127.13.0.1")
  end

  test "should get parameters from index" do
    last_record.parameters = [HostParameter.new(name: 'foo', value: 'bar')]
    get :index, params: { include: ['parameters'] }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    parameters = hosts['results'].map { |host| host['parameters'] }.flatten
    parameter = parameters.find { |param| param['name'] == 'foo' }
    refute parameters.empty?
    assert_equal parameter['value'], 'bar'
  end

  test "should get all_parameters from index" do
    hostgroup = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
    hostgroup.group_parameters = [GroupParameter.new(name: 'foobar', value: 'baz')]
    last_record.parameters = [HostParameter.new(name: 'foo', value: 'bar')]
    last_record.update_attribute(:hostgroup_id, hostgroup.id)
    get :index, params: { include: ['all_parameters'] }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    parameters = hosts['results'].map { |host| host['all_parameters'] }.flatten
    parameter = parameters.find { |param| param['name'] == 'foo' }
    inherited_parameter = parameters.find { |param| param['name'] == 'foobar' }
    refute parameters.empty?
    assert_equal parameter['value'], 'bar'
    assert_equal inherited_parameter['value'], 'baz'
  end

  test "should show individual record" do
    get :show, params: { :id => @host.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test 'should show host with model name' do
    model = FactoryBot.create(:model)
    @host.update_attribute(:model_id, model.id)
    get :show, params: { :id => @host.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal model.id, show_response['model_id']
    assert_equal model.name, show_response['model_name']
  end

  test "should show host owner name" do
    owner = User.first
    host = FactoryBot.create(:host, :owner => owner)
    get :show, params: {:id => host.id}, session: set_session_user
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal owner.name, response["owner_name"]
  end

  test "should show host puppet_ca_proxy_name" do
    # cover issue #16525
    puppet_ca_proxy = smart_proxies(:puppetmaster)
    @host.update_attribute(:puppet_ca_proxy, puppet_ca_proxy)
    get :show, params: { :id => @host.to_param }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('puppet_ca_proxy_name')
    assert_equal puppet_ca_proxy.name, response['puppet_ca_proxy_name']
  end

  test "should show host puppet_proxy_name" do
    # cover issue #16525
    puppet_proxy = smart_proxies(:puppetmaster)
    @host.update_attribute(:puppet_proxy, puppet_proxy)
    get :show, params: { :id => @host.to_param }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('puppet_proxy_name')
    assert_equal puppet_proxy.name, response['puppet_proxy_name']
  end

  test "should create host" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs }
    end
    assert_response :created
  end

  context "lone taxonomy assignment" do
    setup do
      disable_orchestration
    end

    let (:attrs) { valid_attrs.except(:location_id, :organization_id) }

    it 'assigns single taxonomies when only one present' do
      Location.stubs(:one?).returns(true)
      Organization.stubs(:one?).returns(true)
      # We need to make sure we return the correct taxonomies for the resources to match
      Location.stubs(:first).returns(taxonomies(:location1))
      Organization.stubs(:first).returns(taxonomies(:organization1))
      post :create, params: { :host => attrs }
      assert_response :created
      host = Host.unscoped.find(JSON.parse(response.body)['id'])
      assert_equal taxonomies(:location1).id, host.location_id
      assert_equal taxonomies(:organization1).id, host.organization_id
    end

    it "doesn't assign taxonomies when more than one present" do
      Location.stubs(:one?).returns(false)
      Organization.stubs(:one?).returns(false)
      post :create, params: { :host => attrs }
      # Taxonomy id is required so the creation should fail
      assert_response :unprocessable_entity
      res = JSON.parse(response.body)['error']
      assert_not_empty res['errors']['location_id']
      assert_not_empty res['errors']['organization_id']
    end
  end

  test "should create host with build true" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs.merge(:build => true) }
    end
    assert_response :created
    assert_equal true, JSON.parse(@response.body)['build']
  end

  test "should create host with host_parameters_attributes" do
    disable_orchestration
    attrs = [{"name" => "compute_resource_id", "value" => "1"}]
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert_equal attrs[0]['name'], response['parameters'][0]['name'], "Can't create host with valid parameters #{attrs}"
    assert_equal attrs[0]['value'], response['parameters'][0]['value'], "Can't create host with valid parameters #{attrs}"
  end

  test "should create host with host_parameters_attributes sent in a hash" do
    disable_orchestration
    assert_difference('Host.count') do
      attrs = {"0" => {"name" => "compute_resource_id", "value" => "1"}}
      post :create, params: { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
  end

  test "should create interfaces" do
    disable_orchestration

    post :create, params: { :host => basic_attrs.merge!(:interfaces_attributes => nics_attrs) }
    assert_response :created
    assert_equal 2, last_record.interfaces.count

    assert last_record.interfaces.find_by_ip('10.0.0.20').primary?
    assert_equal Nic::Managed, last_record.interfaces.find_by_ip('10.0.0.20').class
    assert_equal Nic::BMC,     last_record.interfaces.find_by_mac('00:11:22:33:44:01').class
  end

  test "should create interfaces sent in a hash" do
    disable_orchestration
    hash_nics_attrs = nics_attrs.inject({}) do |hash, item|
      hash.update((hash.count + 1).to_s => item)
    end

    post :create, params: { :host => basic_attrs.merge!(:interfaces_attributes => hash_nics_attrs) }
    assert_response :created
    assert_equal 2, last_record.interfaces.count

    assert last_record.interfaces.find_by_ip('10.0.0.20').primary?
    assert_equal Nic::Managed, last_record.interfaces.find_by_ip('10.0.0.20').class
    assert_equal Nic::BMC,     last_record.interfaces.find_by_mac('00:11:22:33:44:01').class
  end

  test "should fail with unknown interface type" do
    disable_orchestration

    attrs = basic_attrs.merge!(:interfaces_attributes => nics_attrs)
    attrs[:interfaces_attributes][0][:type] = "unknown"

    post :create, params: { :host => attrs }
    assert_response :unprocessable_entity
    assert_match /Unknown interface type/, JSON.parse(response.body)['error']['message']
  end

  test "should create interfaces from compute profile" do
    disable_orchestration

    compute_attrs = compute_attributes(:with_interfaces)
    post :create, params: { :host => basic_attrs_with_profile(compute_attrs).merge(:interfaces_attributes => nics_attrs) }
    assert_response :created

    as_admin do
      assert_equal compute_attrs.vm_interfaces.count,
        last_record.interfaces.count
      assert_equal expected_compute_attributes(compute_attrs, 0),
        last_record.interfaces.find_by_ip('10.0.0.20').compute_attributes
      assert_equal expected_compute_attributes(compute_attrs, 1),
        last_record.interfaces.find_by_mac('00:11:22:33:44:01').compute_attributes
    end
  end

  test "should create host with managed is false if parameter is passed" do
    disable_orchestration
    post :create, params: { :host => valid_attrs.merge!(:managed => false) }
    assert_response :created
    assert_equal false, last_record.managed?
  end

  test "create applies attribute modifiers on the new host" do
    disable_orchestration
    expect_attribute_modifier(ComputeAttributeMerge, [])
    expect_attribute_modifier(InterfaceMerge, [{:merge_compute_attributes => true}])
    post :create, params: { :host => valid_attrs }
  end

  test "update applies attribute modifiers on the host" do
    disable_orchestration
    expect_attribute_modifier(ComputeAttributeMerge, [])
    expect_attribute_modifier(InterfaceMerge, [{:merge_compute_attributes => true}])
    put :update, params: { :id => @host.to_param, :host => valid_attrs }
  end

  test "update applies attribute modifiers on the host when compute profile is changed" do
    disable_orchestration
    expect_attribute_modifier(ComputeAttributeMerge, [])
    expect_attribute_modifier(InterfaceMerge, [{:merge_compute_attributes => true}])

    compute_attrs = compute_attributes(:with_interfaces)
    put :update, params: { :id => @host.to_param, :host => basic_attrs_with_profile(compute_attrs) }
  end

  test "should update host" do
    put :update, params: { :id => @host.to_param, :host => valid_attrs }
    assert_response :success
  end

  test "should update hostgroup_id of host" do
    host = FactoryBot.create(:host, basic_attrs_with_hg)
    hg = FactoryBot.create(:hostgroup, :with_environment)
    set_environment_taxonomies(hg)
    put :update, params: { :id => host.to_param, :host => { :hostgroup_id => hg.id }}
    assert_response :success
    host.reload
    assert_equal host.hostgroup_id, hg.id
  end

  test 'does not set compute profile when updating arbitrary field' do
    Host.any_instance.expects(:apply_compute_profile).never
    put :update, params: { :id => @host.to_param, :host => { :comment => 'This is a comment' } }
  end

  test "updating interface type isn't allowed" do
    @host = FactoryBot.create(:host, :interfaces => [FactoryBot.build(:nic_bond, :primary => true)])
    nic_id = @host.interfaces.first.id
    put :update, params: { :id => @host.to_param, :host => { :interfaces_attributes => [{ :id => nic_id, :name => 'newname', :type => 'bmc'}] } }

    assert_response :unprocessable_entity
    body = ActiveSupport::JSON.decode(response.body)
    assert_includes body['error']['errors'].keys, 'interfaces.type'
  end

  test "should update interfaces without changing their type" do
    @host = FactoryBot.create(:host, :interfaces => [FactoryBot.build(:nic_bond, :primary => true)])
    nic_id = @host.interfaces.first.id
    put :update, params: { :id => @host.to_param, :host => { :interfaces_attributes => [{ :id => nic_id, :name => 'newname' }] } }

    assert_response :success
    assert_equal('Nic::Bond', Nic::Base.find(nic_id).type)
    assert_equal('newname', Nic::Base.find(nic_id).name)
  end

  test "should update interfaces from compute profile" do
    disable_orchestration

    compute_attrs = compute_attributes(:with_interfaces)

    put :update, params: { :id => @host.to_param, :host => basic_attrs_with_profile(compute_attrs) }
    assert_response :success

    as_admin do
      @host.interfaces.reload
      assert_equal compute_attrs.vm_interfaces.count, @host.interfaces.count
      assert_equal expected_compute_attributes(compute_attrs, 0), @host.interfaces.find_by_primary(true).compute_attributes
      assert_equal expected_compute_attributes(compute_attrs, 1), @host.interfaces.find_by_primary(false).compute_attributes
    end
  end

  test "should update host without :host root node and rails wraps it correctly" do
    put :update, params: { :id => @host.to_param, :name => 'newhostname' }
    request_parameters = @request.env['action_dispatch.request.request_parameters']
    assert request_parameters[:host]
    assert_equal 'newhostname', request_parameters[:host][:name]
    assert_response :success
  end

  test "should destroy hosts" do
    assert_difference('Host.count', -1) do
      delete :destroy, params: { :id => @host.to_param }
    end
    assert_response :success
  end

  test "should show specific status hosts" do
    get :get_status, params: { :id => @host.to_param, :type => 'global' }
    assert_response :success
  end

  test "should be able to create hosts even when restricted" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the host" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :show, params: { :id => host.to_param }
    assert_response :success
  end

  test "should allow to update for restricted user who owns the host" do
    disable_orchestration
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    put :update, params: { :id => host.to_param, :host => valid_attrs }
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the hosts" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    assert_difference('Host.count', -1) do
      setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
      delete :destroy, params: { :id => host.to_param }
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the hosts" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :get_status, params: { :id => host.to_param, :type => 'configuration' }
    assert_response :success
  end

  test "should not allow access to a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not list a host out of users hosts scope" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :index
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    ids = hosts['results'].map { |hash| hash['id'] }
    refute_includes ids, @host.id
    assert_includes ids, host.id
  end

  test "should not update host out of users hosts scope" do
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not delete hosts out of users hosts scope" do
    setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    delete :destroy, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should delete a sub-status" do
    host = FactoryBot.create(:host)
    status = ::HostStatus::BuildStatus.create!(host_id: host.id)
    delete :forget_status, params: { :id => host.to_param, :type => 'build' }
    refute host.host_statuses.include?(status)
  end

  test "should not try to delete global status" do
    host = FactoryBot.create(:host)
    delete :forget_status, params: { :id => host.to_param, :type => 'global' }
    assert JSON.parse(@response.body) == {"error" => "Cannot delete global status."}
  end

  test "should not try to delete nonexistent status" do
    host = FactoryBot.create(:host)
    delete :forget_status, params: { :id => host.to_param, :type => 'doesnt_exist' }
    assert JSON.parse(@response.body) == {"error" => "Status doesnt_exist does not exist."}
  end

  test "should not show status of hosts out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :get_status, params: { :id => @host.to_param, :type => 'configuration' }
    assert_response :not_found
  end

  test "should show hosts vm attributes" do
    host = FactoryBot.create(:host, :compute_resource => compute_resources(:one))
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns(:cpus => 4)
    get :vm_compute_attributes, params: { :id => host.to_param }
    assert_response :success
    data = JSON.parse(@response.body)
    assert_equal data, "cpus" => 4, "memory" => nil
    ComputeResource.any_instance.unstub(:vm_compute_attributes_for)
  end

  def set_remote_user_to(user)
    @request.env['REMOTE_USER'] = user.login
  end

  test "when REMOTE_USER is provided and both authorize_login_delegation{,_api}
        are set, authentication should succeed w/o valid session cookies" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = true
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_host)
    host = Host.first
    get :show, params: { :id => host.to_param, :format => 'json' }
    assert_response :success
    get :show, params: { :id => host.to_param }
    assert_response :success
  end

  test "should disassociate host" do
    host = FactoryBot.create(:host, :on_compute_resource)
    assert host.compute?
    put :disassociate, params: { :id => host.to_param }
    assert_response :success
    refute host.reload.compute?
  end

  def fact_json
    @json ||= read_json_fixture('facts/brslc022.facts.json')
  end

  def test_rebuild_config_optimistic
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => true, "DNS" => true, "DHCP" => true })
    host = FactoryBot.create(:host)
    post :rebuild_config, params: { :id => host.to_param }, session: set_session_user
    assert_response :success
  end

  def test_rebuild_config_pessimistic
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => false, "DNS" => false, "DHCP" => false })
    host = FactoryBot.create(:host)
    post :rebuild_config, params: { :id => host.to_param }, session: set_session_user
    assert_response 422
  end

  def test_rebuild_tftp_config
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => true })
    host = FactoryBot.create(:host)
    post :rebuild_config, params: { :id => host.to_param, :only => ['TFTP'] }, session: set_session_user
    assert_response :success
  end

  context 'fact import' do
    let (:facts) { fact_json['facts'] }
    let (:hostname) { fact_json['name'] }

    test "create valid node from json facts object without certname" do
      User.current = nil
      post :facts, params: { :name => hostname, :facts => facts }, session: set_session_user
      assert_response :success
    end

    test "create valid node from json facts object with certname" do
      User.current = nil
      certname = fact_json['certname']
      post :facts, params: { :name => hostname, :certname => certname, :facts => facts }, session: set_session_user
      assert_response :success
    end

    test "fail to create when facts are invalid" do
      User.current = nil
      invalid_facts = facts.except('operatingsystem')
      post :facts, params: { :name => hostname, :facts => invalid_facts }, session: set_session_user
      assert_response :unprocessable_entity
    end

    context 'taxonomy handling in fact import' do
      let (:loc) { FactoryBot.create(:location) }
      let (:org) { FactoryBot.create(:organization) }

      test 'set host taxonomies to default' do
        Setting[:default_location] = loc.title
        Setting[:default_organization] = org.title
        post :facts, params: { :name => hostname, :facts => facts }
        assert_response :success
        host = Host.find_by_name(hostname)
        assert_equal loc, host.location
        assert_equal org, host.organization
      end

      test 'set host taxonomies to fact' do
        assert_equal 'foreman_location', Setting[:location_fact]
        assert_equal 'foreman_organization', Setting[:organization_fact]
        Setting[:default_location] = ''
        Setting[:default_organization] = ''
        facts['foreman_location'] = loc.title
        facts['foreman_organization'] = org.title
        post :facts, params: { :name => hostname, :facts => facts }
        assert_response :success
        host = Host.find_by_name(hostname)
        assert_equal loc, host.location
        assert_equal org, host.organization
      end

      test 'created domain gets host taxonomies' do
        Setting[:default_location] = loc.title
        Setting[:default_organization] = org.title
        domain_name = 'my_new_domain.com'
        facts['domain'] = domain_name
        post :facts, params: { :name => hostname, :facts => facts }
        assert_response :success
        domain = Domain.unscoped.find_by_name(domain_name)
        assert_equal [loc], domain.locations
        assert_equal [org], domain.organizations
      end

      test "existing domain doesn't get host taxonomies" do
        Setting[:default_location] = loc.title
        Setting[:default_organization] = org.title
        domain = Domain.first
        refute_includes domain.locations, loc
        refute_includes domain.organizations, org
        facts['domain'] = domain.name
        post :facts, params: { :name => hostname, :facts => facts }
        assert_response :success
        domain.reload
        refute_includes domain.locations, loc
        refute_includes domain.organizations, org
      end
    end

    test 'set hostgroup when foreman_hostgroup present in facts' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      hostgroup = FactoryBot.create(:hostgroup)
      facts['foreman_hostgroup'] = hostgroup.title
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :success
      assert_equal hostgroup.id, Host.find_by(:name => hostname).hostgroup_id
    end

    test 'assign hostgroup attributes when foreman_hostgroup present in facts' do
      Setting[:create_new_host_when_facts_are_uploaded] = true
      hostgroup = FactoryBot.create(:hostgroup, :with_rootpass)
      facts['foreman_hostgroup'] = hostgroup.title
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :success
      assert_equal hostgroup.root_pass, Host.find_by(:name => hostname).root_pass
    end

    test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = false
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :facts, params: { :name => hostname, :facts => facts }
      assert_nil @controller.detected_proxy
      assert_response :success
    end

    test 'hosts with a registered smart proxy on should import facts successfully' do
      stub_smart_proxy_v2_features
      proxy = smart_proxies(:puppetmaster)
      proxy.update_attribute(:url, 'https://factsimporter.foreman')

      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = false

      host = URI.parse(proxy.url).host
      Resolv.any_instance.stubs(:getnames).returns([host])
      post :facts, params: { :name => hostname, :facts => facts }
      assert_equal proxy, @controller.detected_proxy
      assert_response :success
    end

    test 'hosts without a registered smart proxy on should not be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = false

      Resolv.any_instance.stubs(:getnames).returns(['another.host'])
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :forbidden
    end

    test 'hosts with a registered smart proxy and SSL cert should import facts successfully' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :success
    end

    test 'hosts without a registered smart proxy but with an SSL cert should not be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :forbidden
    end

    test 'hosts with an unverified SSL cert should not be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=secure.host'
      @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :forbidden
    end

    test 'when "require_ssl_smart_proxies" and "require_ssl" are true, HTTP requests should not be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true
      SETTINGS[:require_ssl] = true

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :forbidden
    end

    test 'when "require_ssl_smart_proxies" is true and "require_ssl" is false, HTTP requests should be able to import facts' do
      User.current = users(:one) # use an unprivileged user, not apiadmin
      # since require_ssl_smart_proxies is only applicable to HTTPS connections, both should be set
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :facts, params: { :name => hostname, :facts => facts }
      assert_response :success
    end

    test "when a bad :type is requested, :unprocessable_entity is returned" do
      User.current = nil
      post :facts, params: { :name => hostname, :facts => facts, :type => "Host::Invalid" }, session: set_session_user
      assert_response :unprocessable_entity
      assert JSON.parse(response.body)['message'] =~ /ERF42-3624/
    end

    test "when the imported host failed to save, :unprocessable_entity is returned" do
      Host::Managed.any_instance.stubs(:save).returns(false)
      Nic::Managed.any_instance.stubs(:save).returns(false)
      errors = ActiveModel::Errors.new(Host::Managed.new)
      errors.add :foo, 'A stub failure'
      Host::Managed.any_instance.stubs(:errors).returns(errors)
      User.current = nil
      post :facts, params: { :name => hostname, :facts => facts }, session: set_session_user
      assert_response :unprocessable_entity
      assert_equal 'A stub failure', JSON.parse(response.body)['error']['errors']['foo'].first
    end
  end
  test 'non-admin user with power_host permission can boot a vm' do
    @bmchost = FactoryBot.create(:host, :managed)
    FactoryBot.create(:nic_bmc, :host => @bmchost, :subnet => subnets(:one))
    ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
    role = FactoryBot.create(:role, :name => 'power_hosts')
    role.add_permissions!(['power_hosts'])
    api_user = FactoryBot.create(:user)
    api_user.update_attribute :roles, [role]
    as_user(api_user) do
      put :power, params: { :id => @bmchost.to_param, :power_action => 'status' }
    end
    assert_response :success
    assert @response.body =~ /on/
  end

  context 'BMC proxy operations' do
    setup :initialize_proxy_ops

    def initialize_proxy_ops
      User.current = users(:apiadmin)
      @bmchost = FactoryBot.create(:host, :managed)
      @bmc_nic = FactoryBot.create(:nic_bmc, :host => @bmchost, :subnet => subnets(:one))
    end

    test "power call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
      put :power, params: { :id => @bmchost.to_param, :power_action => 'status' }
      assert_response :success
      assert @response.body =~ /on/
    end

    test "wrong power call fails gracefully" do
      put :power, params: { :id => @bmchost.to_param, :power_action => 'wrongmethod' }
      assert_response 422
      assert @response.body =~ /available methods are/
    end

    test "boot call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:boot).with(:function => 'bootdevice', :device => 'bios').
                                              returns({ "action" => "bios", "result" => true } .to_json)
      put :boot, params: { :id => @bmchost.to_param, :device => 'bios' }
      assert_response :success
      assert @response.body =~ /true/
    end

    test "wrong boot call to interface fails gracefully" do
      put :boot, params: { :id => @bmchost.to_param, :device => 'wrongbootdevice' }
      assert_response 422
      assert @response.body =~ /available devices are/
    end

    context 'permissions' do
      setup do
        setup_user 'view', 'hosts'
        setup_user 'ipmi_boot', 'hosts'
      end

      test 'returns error for non-admin user if BMC is not available' do
        put :boot, params: { :id => @host.to_param, :device => 'bios' },
          session: set_session_user.merge(:user => @one.id)
        assert_match(/No BMC NIC available/, response.body)
        assert_response :unprocessable_entity
      end

      test 'responds correctly for non-admin user if BMC is available' do
        ProxyAPI::BMC.any_instance.stubs(:boot).
          with(:function => 'bootdevice', :device => 'bios').
          returns({ "action" => "bios", "result" => true } .to_json)
        put :boot, params: { :id => @bmchost.to_param, :device => 'bios' },
          session: set_session_user.merge(:user => @one.id)
        assert_response :success
      end
    end

    test "should return correct total and subtotal metadata if search param is passed" do
      FactoryBot.create_list(:host, 8)
      get :index, params: { :search => @bmchost.name }
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal response['search'], @bmchost.name
      assert_equal 10, response['total'] # one from setup, one from bmc setup, 8 here
      assert_equal 1, response['subtotal']
      assert_equal @bmchost.name, response['search']
    end
  end

  test 'template should return rendered template' do
    managed_host = FactoryBot.create(:host, :managed)
    Host::Managed.any_instance.stubs(:provisioning_template).with({:kind => 'provision'}).returns(FactoryBot.create(:provisioning_template))
    get :template, params: { :id => managed_host.to_param, :kind => 'provision' }
    assert_response :success
    assert @response.body =~ /template content/
  end

  test 'wrong template name should return not found' do
    managed_host = FactoryBot.create(:host, :managed)
    Host::Managed.any_instance.stubs(:provisioning_template).with({:kind => 'provitamin'}).returns(nil)
    get :template, params: { :id => managed_host.to_param, :kind => 'provitamin' }
    assert_response :not_found
  end

  context 'search by hostgroup' do
    def setup
      @hostgroup = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @managed_host = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup)
    end

    test "should search host by hostgroup name" do
      get :index, params: { :search => "hostgroup_name = #{@hostgroup.name}" }
      assert_equal [@managed_host], assigns(:hosts)
    end

    test "should search host by hostgroup title" do
      get :index, params: { :search => "hostgroup_title = #{@hostgroup.title}" }
      assert_equal [@managed_host], assigns(:hosts)
    end
  end

  context 'host list after passing hostgroup filter' do
    def setup
      @hg1 = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @unassigned_hg2 = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @managed_host = FactoryBot.create(:host, :managed, :hostgroup => @hg1)
    end

    test "should return empty host list by unassigned hostgroup id" do
      get :index, params: { :hostgroup_id => @unassigned_hg2.id }
      assert_equal [], assigns(:hosts)
    end

    test "should return a host in list" do
      get :index, params: { :hostgroup_id => @hg1.id }
      assert_equal [@managed_host], assigns(:hosts)
    end
  end

  test "user without view_params permission can't see host parameters" do
    host_with_parameter = FactoryBot.create(:host, :with_parameter)
    setup_user "view", "hosts"
    get :show, params: { :id => host_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see host parameters" do
    host_with_parameter = FactoryBot.create(:host, :with_parameter)
    setup_user "view", "hosts"
    setup_user "view", "params"
    get :show, params: { :id => host_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  test "should get ENC values of host" do
    host = FactoryBot.create(:host, :with_puppetclass)
    get :enc, params: { :id => host.to_param }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    puppet_class = response['data']['classes'].keys rescue nil
    assert_equal host.puppetclasses.map(&:name), puppet_class
  end

  context 'parameters type' do
    test "should create an host parameter with parameter type" do
      host = FactoryBot.build(:host)
      host_params = [{:name => "foo", :value => 42, :parameter_type => 'integer'}]
      post :create, params: { host: host.attributes.merge(parameters: host_params) }
      assert_response :success
    end

    test "should show an host parameter with parameter type" do
      host = FactoryBot.create(:host)
      host.host_parameters.create!(:name => "foo", :value => 42, :parameter_type => 'integer')
      get :show, params: { :id => host.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 42, show_response['parameters'].first['value'].to_i
      assert_equal 'integer', show_response['parameters'].first['parameter_type']
    end

    test "should create an host parameter with default parameter type" do
      host = FactoryBot.build(:host)
      host_params = [{ :name => "foo", :value => 42 }]
      post :create, params: { host: host.attributes.merge(parameters: host_params) }
      assert_response :success
    end

    test "should show an host parameter with default parameter type" do
      host = FactoryBot.create(:host)
      host.host_parameters.create!(:name => "foo", :value => 42)
      get :show, params: { :id => host.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 42, show_response['parameters'].first['value'].to_i
      assert_equal 'string', show_response['parameters'].first['parameter_type']
    end
  end

  context 'hidden parameters' do
    test "should create an host parameter with hidden_value" do
      host = FactoryBot.build(:host)
      host_params = [{:name => "foo", :value => "bar", :hidden_value => true}]
      post :create, params: { host: host.attributes.merge(parameters: host_params) }
      assert_response :success
    end

    test "should show a host parameter as hidden unless show_hidden_parameters is true" do
      host = FactoryBot.create(:host)
      host.host_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => host.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a host parameter as unhidden when show_hidden_parameters is true" do
      host = FactoryBot.create(:host)
      host.host_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => host.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing host parameters using indexed hash format" do
    host = FactoryBot.create(:host, :with_parameter)
    host_param = host.parameters.first
    put :update, params: { :id => host.id, :host => { :host_parameters_attributes => { "0" => { :name => host_param.name, :value => "new_value" } } } }
    assert_response :success
  end

  test "should update existing host parameters using array format" do
    host = FactoryBot.create(:host, :with_parameter)
    host_param = host.parameters.first
    put :update, params: { :id => host.id, :host => { :host_parameters_attributes => [{ :name => host_param.name, :value => "new_value" }] } }
    assert_response :success
  end

  context 'import from compute resource' do
    setup do
      disable_orchestration
      Fog.mock!
    end
    teardown { Fog.unmock! }

    let(:domain) do
      FactoryBot.create(
        :domain,
        :name => 'virt.bos.redhat.com',
        :location_ids => [basic_attrs[:location_id]],
        :organization_ids => [basic_attrs[:organization_id]]
      )
    end
    let(:compute_resource) do
      cr = FactoryBot.create(
        :compute_resource,
        :vmware,
        :uuid => 'Solutions',
        :location_ids => [basic_attrs[:location_id]],
        :organization_ids => [basic_attrs[:organization_id]]
      )
      ComputeResource.find_by_id(cr.id)
    end
    let(:uuid) { '5032c8a5-9c5e-ba7a-3804-832a03e16381' }
    let(:import_attrs) { basic_attrs.except(:name, :domain_id, :compute_resource_id) }
    let(:host_attrs) do
      import_attrs.merge(
        :compute_resource_id => compute_resource.id,
        :uuid => uuid,
        :ip => '10.0.0.20',
        :build => true
      )
    end

    test 'should create a host' do
      assert domain
      assert_difference('Host.count') do
        post :create, params: { :host => host_attrs }
      end
      assert_response :created
      body = ActiveSupport::JSON.decode(@response.body)
      assert_not_nil body['id']
      as_admin do
        host = Host.find_by_id(body['id'])
        assert_equal 'dhcp75-197.virt.bos.redhat.com', host.name
        assert_equal domain, host.domain
        assert_equal '00:50:56:a9:00:28', host.mac
        assert_equal true, host.build
      end
    end

    test 'should not import if associated host exists' do
      FactoryBot.create(:host, :on_compute_resource, :uuid => uuid, :compute_resource => compute_resource)
      post :create, params: { :host => host_attrs }
      assert_response :unprocessable_entity
      body = ActiveSupport::JSON.decode(@response.body)
      assert_includes body['error']['errors'].keys, 'uuid'
    end
  end

  test "host with two interfaces should get ips assigned on both interfaces" do
    disable_orchestration
    subnet1 = FactoryBot.create(:subnet_ipv4, :name => 'my_subnet1', :network => '192.168.2.0', :from => '192.168.2.10',
                                  :to => '192.168.2.12', :dns_primary => '192.168.2.2', :gateway => '192.168.2.3',
                                  :ipam => IPAM::MODES[:db], :location_ids => [basic_attrs[:location_id]],
                                  :organization_ids => [basic_attrs[:organization_id]])
    subnet2 = FactoryBot.create(:subnet_ipv4, :name => 'my_subnet2', :network => '192.168.3.0', :from => '192.168.3.10',
                                 :to => '192.168.3.12', :dns_primary => '192.168.3.2', :gateway => '192.168.3.3',
                                 :ipam => IPAM::MODES[:db], :location_ids => [basic_attrs[:location_id]],
                                 :organization_ids => [basic_attrs[:organization_id]])
    assert_difference('Host.count') do
      post :create, params: { :host => basic_attrs.merge!(:interfaces_attributes => [{ :primary => true, :mac => '00:11:22:33:44:00',
                      :subnet_id => subnet1.id}, { :primary => false, :mac => '00:11:22:33:44:01', :subnet_id => subnet2.id}]) }
    end
    assert_response :created
    assert_equal 2, last_record.interfaces.count
    assert_equal '192.168.2.10', last_record.interfaces.find_by_mac('00:11:22:33:44:00').ip
    assert_equal '192.168.3.10', last_record.interfaces.find_by_mac('00:11:22:33:44:01').ip
  end

  test "should not create host only with user owner type" do
    assert_difference('Host.count', 0) do
      post :create, params: { :host => valid_attrs.merge(:owner_type => 'User') }
    end
    assert_response :unprocessable_entity, "Can create host only with user owner type and without specifying owner"
    assert_match 'owner must be specified', @response.body
  end

  test "should not create host only with usergroup owner type" do
    assert_difference('Host.count', 0) do
      post :create, params: { :host => valid_attrs.merge(:owner_type => 'Usergroup') }
    end
    assert_response :unprocessable_entity, "Can create host only with usergroup owner type and without specifying owner"
    assert_match 'owner must be specified', @response.body
  end

  test "should not update with invalid name" do
    put :update, params: { :id => @host.id, :host => {:name => ''} }
    assert_response :unprocessable_entity, "Can update host with empty name"
    assert_not_equal '', @host.name
  end

  test "should create with valid comment" do
    comment = RFauxFactory.gen_alpha
    post :create, params: { :host => valid_attrs.merge(:comment => comment) }
    assert_response :created
    assert_equal comment, JSON.parse(@response.body)['comment'], "Can't create host with valid comment #{comment}"
  end

  test "should create with enabled parameter" do
    post :create, params: { :host => valid_attrs.merge(:enabled => false) }
    assert_response :created
    assert_equal false, JSON.parse(@response.body)['enabled'], "Can't create host with enabled parameter false"
  end

  test "should create with managed parameter" do
    post :create, params: { :host => valid_attrs.merge(:managed => true) }
    assert_response :created
    assert_equal true, JSON.parse(@response.body)['managed'], "Can't create host with managed parameter true"
  end

  test "should create with build provision method" do
    post :create, params: { :host => valid_attrs.merge(:provision_method => 'build') }
    assert_response :created
    assert_equal JSON.parse(@response.body)['provision_method'], 'build', "Can't create host with build provision method"
  end

  test "should create with image provision method" do
    post :create, params: { :host => valid_attrs.merge(:provision_method => 'image') }
    assert_response :created
    assert_equal JSON.parse(@response.body)['provision_method'], 'image', "Can't create host with image provision method"
  end

  test "should create with puppet ca proxy" do
    smart_proxy = smart_proxies(:puppetmaster)
    post :create, params: { :host => valid_attrs.merge(:puppet_ca_proxy_id => smart_proxy.id) }
    assert_response :created
    assert_equal smart_proxy.name, JSON.parse(@response.body)['puppet_ca_proxy']['name'], "Can't create host with smart proxy #{smart_proxy}"
  end

  test "should create with puppet proxy" do
    post :create, params: { :host => valid_attrs }
    assert_response :created
    assert_equal smart_proxies(:puppetmaster).name, JSON.parse(@response.body)['puppet_proxy']['name'], "Can't create host with puppet proxy #{smart_proxies(:puppetmaster)}"
  end

  test "should get per page" do
    per_page = rand(1..1000)
    get :index, params: { :per_page => per_page }
    assert_equal per_page, JSON.parse(@response.body)['per_page']
  end

  test "should not update with invalid mac" do
    mac = RFauxFactory.gen_alpha
    put :update, params: { :id => @host.id, :host => {:mac => mac} }
    assert_response :unprocessable_entity, "Can update host with invalid mac #{mac}"
    assert_match "'#{mac}' is not a valid MAC address", @response.body
  end

  test "should update build parameter with false value" do
    host = FactoryBot.create(:host, valid_attrs.merge(:managed => true, :build => true))
    put :update, params: { :id => host.id, :host => { :build => false} }
    assert_response :success
    assert_equal false, JSON.parse(@response.body)['build'], "Can't update host with false build parameter"
  end

  test "should update build parameter with true value" do
    host = FactoryBot.create(:host, valid_attrs.merge(:managed => true, :build => false))
    put :update, params: { :id => host.id, :host => { :build => true} }
    assert_response :success
    assert_equal true, JSON.parse(@response.body)['build'], "Can't update host with true build parameter"
  end

  test "should update host with valid comment" do
    new_comment = 'another valid comment'
    host = FactoryBot.create(:host, valid_attrs.merge(:comment => 'this is a valid comment'))
    put :update, params: { :id => host.id, :host => { :comment => new_comment} }
    assert_response :success
    assert_equal new_comment, JSON.parse(@response.body)['comment'], "Can't update host with valid comment #{new_comment}"
  end

  test "should update enabled parameter with false value" do
    host = FactoryBot.create(:host, valid_attrs.merge(:enabled => true))
    put :update, params: { :id => host.id, :host => { :enabled => false} }
    assert_response :success
    assert_equal false, JSON.parse(@response.body)['enabled'], "Can't update host with false enabled parameter"
  end

  test "should update enabled parameter with true value" do
    host = FactoryBot.create(:host, valid_attrs.merge(:enabled => false))
    put :update, params: { :id => host.id, :host => { :enabled => true} }
    assert_response :success
    assert_equal true, JSON.parse(@response.body)['enabled'], "Can't update host with true enabled parameter"
  end

  test "should update host with parameters attributes" do
    attrs = [{:name => "attr_name", :value => "attr_value"}]
    post :create, params: { :id => @host.id, :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal attrs[0][:name], response['parameters'][0]['name'], "Can't update host with valid parameters #{attrs}"
    assert_equal attrs[0][:value], response['parameters'][0]['value'], "Can't update host with valid parameters #{attrs}"
  end

  test "should update with valid ip" do
    ip = RFauxFactory.gen_ipaddr
    put :update, params: { :id => @host.id, :host => { :ip => ip} }
    assert_response :success
    assert_equal ip, JSON.parse(@response.body)['ip'], "Can't update host with valid ip #{ip}"
  end

  test "should update with valid mac" do
    mac = RFauxFactory.gen_mac(multicast: false)
    put :update, params: { :id => @host.id, :host => { :mac => mac} }
    assert_response :success
    assert_equal mac, JSON.parse(@response.body)['mac'], "Can't update host with valid mac #{mac}"
  end

  test "should update with managed parameter true" do
    host = FactoryBot.create(:host, valid_attrs.merge(:managed => false))
    put :update, params: { :id => host.id, :host => { :managed => true} }
    assert_response :success
    assert_equal true, JSON.parse(@response.body)['managed'], "Can't update host with managed parameter true"
  end

  test "should update with managed parameter false" do
    host = FactoryBot.create(:host, valid_attrs.merge(:managed => true))
    put :update, params: { :id => host.id, :host => { :managed => false} }
    assert_response :success
    assert_equal false, JSON.parse(@response.body)['managed'], "Can't update host with managed parameter false"
  end

  test "should update with valid name" do
    name = RFauxFactory.gen_alpha.downcase
    put :update, params: { :id => @host.id, :host => { :name => name} }
    assert_response :success
    assert_equal name, JSON.parse(@response.body)['name'], "Can't update host with valid name #{name}"
  end

  test "should update with user owner" do
    owner_type = 'User'
    user = FactoryBot.create(:user, :locations => [taxonomies(:location1)], :organizations => [taxonomies(:organization1)])
    put :update, params: { :id => @host.id, :host => { :owner_type => owner_type, :owner_id => user.id} }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal owner_type, response['owner_type'], "Can't update host with user owner"
    assert_equal user.id, response['owner_id'], "Can't update host with user #{user}"
  end

  test "should update with usergroup owner" do
    owner_type = 'Usergroup'
    usergroup = FactoryBot.create(:usergroup)
    put :update, params: { :id => @host.id, :host => { :owner_type => owner_type, :owner_id => usergroup.id} }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal owner_type, response['owner_type'], "Can't update host with usergroup owner"
    assert_equal usergroup.id, response['owner_id'], "Can't update host with usergroup #{usergroup}"
  end

  test "should update with puppet ca proxy" do
    puppet_ca_proxy = FactoryBot.create(:puppet_ca_smart_proxy)
    put :update, params: { :id => @host.id, :host => valid_attrs.merge(:puppet_ca_proxy_id => puppet_ca_proxy.id) }
    assert_response :success
    assert_equal puppet_ca_proxy['name'], JSON.parse(@response.body)['puppet_ca_proxy']['name'], "Can't update host with puppet ca proxy #{puppet_ca_proxy}"
  end

  test "should update with puppet class" do
    environment = environments(:testing)
    set_environment_taxonomies(@host, environment)
    puppetclass = Puppetclass.find_by_name('git')
    put :update, params: { :id => @host.id, :host => valid_attrs.merge(:environment_id => environment.id, :puppetclass_ids => [puppetclass.id]) }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal environment.id, response['environment_id'], "Can't update host with environment #{environment}"
    assert_equal puppetclass.id, response['puppetclasses'][0]['id'], "Can't update host with puppetclass #{puppetclass}"
  end

  test "should update with puppet proxy" do
    puppet_proxy = FactoryBot.create(:puppet_smart_proxy)
    put :update, params: { :id => @host.id, :host => valid_attrs.merge(:puppet_proxy_id => puppet_proxy.id) }
    assert_response :success
    assert_equal puppet_proxy['name'], JSON.parse(@response.body)['puppet_proxy']['name'], "Can't update host with puppet proxy #{puppet_proxy}"
  end

  # This is a test of the base_controller functionality, but we need to use a real endpoint
  # to test the API response metadata is returned correctly
  describe 'should create correct subtotals' do
    before do
      @empty_org = Organization.find_by_name("Empty Organization")
      as_admin do
        FactoryBot.create_list(:host, 10, organization: @empty_org)
      end
    end

    it 'with no search parameter' do
      get :index, params: { per_page: 5 }
      hosts_response = ActiveSupport::JSON.decode(@response.body)
      total_host_count = Host.all.count

      assert_response :success
      assert_equal hosts_response["subtotal"], total_host_count
      assert_equal hosts_response["total"], total_host_count
      assert hosts_response["subtotal"] > hosts_response["per_page"]
    end

    it 'with search parameter' do
      get :index, params: { per_page: 5, search: "organization = \"#{@empty_org.name}\""}
      hosts_response = ActiveSupport::JSON.decode(@response.body)
      empty_org_host_count = @empty_org.hosts.count
      total_host_count = Host.all.count

      assert_response :success
      assert_not_equal total_host_count, empty_org_host_count
      assert_equal hosts_response["subtotal"], empty_org_host_count
      assert_equal hosts_response["total"], total_host_count
      assert hosts_response["subtotal"] > hosts_response["per_page"]
    end
  end

  describe '/host/:id/power_status' do
    let(:host) { FactoryBot.create(:host, compute_resource: FactoryBot.create(:vmware_cr)) }

    setup { Fog.mock! }
    teardown { Fog.unmock! }

    test 'show power status for a host' do
      expected_resp = {
        "id" => host.id,
        "state" => "on",
        "title" => "On",
      }

      Host.any_instance.stubs(:supports_power?).returns(true)
      Host.any_instance.stubs(:supports_power_and_running?).returns(true)
      get :power_status, params: { :id => host.id }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse @response.body
      assert_equal(expected_resp.sort, response.sort)
    end

    test 'show power status for a powered off host' do
      expected_resp = {
        "id" => host.id,
        "state" => "off",
        "title" => "Off",
      }

      Host.any_instance.stubs(:supports_power?).returns(true)
      Host.any_instance.stubs(:supports_power_and_running?).returns(false)
      get :power_status, params: { :id => host.id }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse @response.body
      assert_equal(expected_resp.sort, response.sort)
    end

    test 'show power status for a host that has no power' do
      expected_resp = {
        "id" => host.id,
        "state" => "na",
        "title" => 'N/A',
        "statusText" => "Power operations are not enabled on this host.",
      }

      Host.any_instance.stubs(:supports_power?).returns(false)
      get :power_status, params: { :id => host.id }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse @response.body
      assert_equal(expected_resp.sort, response.sort)
    end

    test 'shows power status for bmc hosts' do
      bmchost = FactoryBot.create(:host, :managed)
      FactoryBot.create(:nic_bmc, :host => bmchost, :subnet => subnets(:one))
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")

      expected_resp = {
        "id" => bmchost.id,
        "state" => "on",
        "title" => "On",
      }

      get :power_status, params: { :id => bmchost.id }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse @response.body
      assert_equal(expected_resp.sort, response.sort)
    end

    test 'show power status for a host that has an exception' do
      expected_resp = {
        "id" => host.id,
        "state" => "na",
        "title" => "N/A",
        "statusText" => "Failed to fetch power status: ERF42-9958 [Foreman::Exception]: Unknown power management support - can't continue",
      }

      Host.any_instance.stubs(:supports_power?).returns(true)
      Host.any_instance.stubs(:power).raises(::Foreman::Exception.new(N_("Unknown power management support - can't continue")))
      get :power_status, params: { :id => host.id }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse @response.body
      assert_equal(expected_resp.sort, response.sort)
    end

    test 'do not provide power state on an unknown host' do
      get :power_status, params: { :id => 'no-such-host' }, session: set_session_user, xhr: true
      assert_response :not_found
    end
  end
end
