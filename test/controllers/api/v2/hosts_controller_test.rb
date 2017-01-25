require 'test_helper'
require 'controllers/shared/pxe_loader_test'

class Api::V2::HostsControllerTest < ActionController::TestCase
  include ::PxeLoaderTest

  def setup
    @host = FactoryGirl.create(:host)
    @ptable = FactoryGirl.create(:ptable)
    @ptable.operatingsystems = [ Operatingsystem.find_by_name('Redhat') ]
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
      :root_pass           => "xybxa6JUkz63w",
      :location_id         => taxonomies(:location1).id,
      :organization_id     => taxonomies(:organization1).id
    }
  end

  def valid_attrs
    net_attrs = {
      :ip  => '10.0.0.20',
      :mac => '52:53:00:1e:85:93'
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
      :hostgroup_id => Hostgroup.first.id
    }
    basic_attrs.merge(hostgroup_attr)
  end

  def nics_attrs
    [{
      :primary => true,
      :ip => '10.0.0.20',
      :mac => '00:11:22:33:44:00'
    },{
      :type => 'bmc',
      :provider => 'IPMI',
      :mac => '00:11:22:33:44:01'
    },{
      :mac => '00:11:22:33:44:02',
      :_destroy => 1
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

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
  end

  test "should include registered scope on index" do
    # remember the previous state
    old_scopes = Api::V2::HostsController.scopes_for(:index).dup

    scope_accessed = false
    Api::V2::HostsController.add_scope_for(:index) do |base_scope|
      scope_accessed = true
      base_scope
    end
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?

    #restore the previous state
    new_scopes = Api::V2::HostsController.scopes_for(:index)
    new_scopes.keep_if { |s| old_scopes.include?(s) }
  end

  test "should get attributes in ordered index" do
    last_record.update(ip: "127.13.0.1")
    get :index, order: "mac"
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    ip_addresses = hosts["results"].map { |host| host["ip"] }
    refute ip_addresses.empty?
    assert_includes(ip_addresses, "127.13.0.1")
  end

  test "should get parameters from index" do
    last_record.parameters = [HostParameter.new(name: 'foo', value: 'bar')]
    get :index, include: ['parameters']
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    parameters = hosts['results'].map { |host| host['parameters'] }.flatten
    parameter = parameters.select { |param| param['name'] == 'foo' }.first
    refute parameters.empty?
    assert_equal parameter['value'], 'bar'
  end

  test "should get all_parameters from index" do
    hostgroup = FactoryGirl.create(:hostgroup, :with_parent, :with_domain, :with_os)
    hostgroup.group_parameters = [GroupParameter.new(name: 'foobar', value: 'baz')]
    last_record.parameters = [HostParameter.new(name: 'foo', value: 'bar')]
    last_record.update_attribute(:hostgroup_id, hostgroup.id)
    get :index, include: ['all_parameters']
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    parameters = hosts['results'].map { |host| host['all_parameters'] }.flatten
    parameter = parameters.select { |param| param['name'] == 'foo' }.first
    inherited_parameter = parameters.select { |param| param['name'] == 'foobar' }.first
    refute parameters.empty?
    assert_equal parameter['value'], 'bar'
    assert_equal inherited_parameter['value'], 'baz'
  end

  test "should show individual record" do
    get :show, { :id => @host.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test 'should show host with model name' do
    model = FactoryGirl.create(:model)
    @host.update_attribute(:model_id, model.id)
    get :show, { :id => @host.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal model.id, show_response['model_id']
    assert_equal model.name, show_response['model_name']
  end

  test "should create host" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, { :host => valid_attrs }
    end
    assert_response :created
  end

  test "should create host with host_parameters_attributes" do
    disable_orchestration
    Foreman::Deprecation.expects(:api_deprecation_warning).with('Field host_parameters_attributes.nested ignored')
    assert_difference('Host.count') do
      attrs = [{"name" => "compute_resource_id", "value" => "1", "nested" => "true"}]
      post :create, { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
  end

  test "should create host with host_parameters_attributes sent in a hash" do
    disable_orchestration
    Foreman::Deprecation.expects(:api_deprecation_warning).with('Field host_parameters_attributes.nested ignored')
    assert_difference('Host.count') do
      attrs = {"0" => {"name" => "compute_resource_id", "value" => "1", "nested" => "true"}}
      post :create, { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
  end

  test "should create interfaces" do
    disable_orchestration

    post :create, { :host => basic_attrs.merge!(:interfaces_attributes => nics_attrs) }
    assert_response :created
    assert_equal 2, last_record.interfaces.count

    assert last_record.interfaces.find_by_mac('00:11:22:33:44:00').primary?
    assert_equal Nic::Managed, last_record.interfaces.find_by_mac('00:11:22:33:44:00').class
    assert_equal Nic::BMC,     last_record.interfaces.find_by_mac('00:11:22:33:44:01').class
  end

  test "should create interfaces sent in a hash" do
    disable_orchestration
    hash_nics_attrs = nics_attrs.inject({}) do |hash, item|
      hash.update((hash.count + 1).to_s => item)
    end

    post :create, { :host => basic_attrs.merge!(:interfaces_attributes => hash_nics_attrs) }
    assert_response :created
    assert_equal 2, last_record.interfaces.count

    assert last_record.interfaces.find_by_mac('00:11:22:33:44:00').primary?
    assert_equal Nic::Managed, last_record.interfaces.find_by_mac('00:11:22:33:44:00').class
    assert_equal Nic::BMC,     last_record.interfaces.find_by_mac('00:11:22:33:44:01').class
  end

  test "should fail with unknown interface type" do
    disable_orchestration

    attrs = basic_attrs.merge!(:interfaces_attributes => nics_attrs)
    attrs[:interfaces_attributes][0][:type] = "unknown"

    post :create, { :host => attrs }
    assert_response :unprocessable_entity
    assert_match /Unknown interface type/, JSON.parse(response.body)['error']['message']
  end

  test "should create interfaces from compute profile" do
    disable_orchestration

    compute_attrs = compute_attributes(:with_interfaces)
    post :create, { :host => basic_attrs_with_profile(compute_attrs).merge(:interfaces_attributes =>  nics_attrs) }
    assert_response :created

    assert_equal compute_attrs.vm_interfaces.count, last_record.interfaces.count
    assert_equal expected_compute_attributes(compute_attrs, 0), last_record.interfaces.find_by_mac('00:11:22:33:44:00').compute_attributes
    assert_equal expected_compute_attributes(compute_attrs, 1), last_record.interfaces.find_by_mac('00:11:22:33:44:01').compute_attributes
  end

  test "should create host with managed is false if parameter is passed" do
    disable_orchestration
    post :create, { :host => valid_attrs.merge!(:managed => false) }
    assert_response :created
    assert_equal false, last_record.managed?
  end

  test "create applies attribute modifiers on the new host" do
    disable_orchestration
    expect_attribute_modifier(ComputeAttributeMerge, [])
    expect_attribute_modifier(InterfaceMerge, [{:merge_compute_attributes => true}])
    post :create, { :host => valid_attrs }
  end

  test "update applies attribute modifiers on the host" do
    disable_orchestration
    expect_attribute_modifier(ComputeAttributeMerge, [])
    expect_attribute_modifier(InterfaceMerge, [{:merge_compute_attributes => true}])
    put :update, { :id => @host.to_param, :host => valid_attrs }
  end

  test "should update host" do
    put :update, { :id => @host.to_param, :host => valid_attrs }
    assert_response :success
  end

  test "should update hostgroup_id of host" do
    @host = FactoryGirl.create(:host, basic_attrs_with_hg)
    put :update, { :id => @host.to_param, :hostgroup_id => Hostgroup.last.id }
    assert_response :success
  end

  test "should update interfaces from compute profile" do
    disable_orchestration

    compute_attrs = compute_attributes(:with_interfaces)

    put :update, { :id => @host.to_param, :host => basic_attrs_with_profile(compute_attrs) }
    assert_response :success

    @host.interfaces.reload
    assert_equal compute_attrs.vm_interfaces.count, @host.interfaces.count
    assert_equal expected_compute_attributes(compute_attrs, 0), @host.interfaces.find_by_primary(true).compute_attributes
    assert_equal expected_compute_attributes(compute_attrs, 1), @host.interfaces.find_by_primary(false).compute_attributes
  end

  test "should update host without :host root node and rails wraps it correctly" do
    put :update, { :id => @host.to_param, :name => 'newhostname' }
    request_parameters = @request.env['action_dispatch.request.request_parameters']
    assert request_parameters[:host]
    assert_equal 'newhostname', request_parameters[:host][:name]
    assert_response :success
  end

  test "should destroy hosts" do
    assert_difference('Host.count', -1) do
      delete :destroy, { :id => @host.to_param }
    end
    assert_response :success
  end

  test "should show status hosts" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with(regexp_matches(%r{/status route is deprecated}))
    get :status, { :id => @host.to_param }
    assert_response :success
  end

  test "should show specific status hosts" do
    get :get_status, { :id => @host.to_param, :type => 'global' }
    assert_response :success
  end

  test "should be able to create hosts even when restricted" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, { :host => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the host" do
    host = FactoryGirl.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :show, { :id => host.to_param }
    assert_response :success
  end

  test "should allow to update for restricted user who owns the host" do
    disable_orchestration
    host = FactoryGirl.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    put :update, { :id => host.to_param, :host => valid_attrs }
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the hosts" do
    host = FactoryGirl.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    assert_difference('Host.count', -1) do
      setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
      delete :destroy, { :id => host.to_param }
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the hosts" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with(regexp_matches(%r{/status route is deprecated}))
    host = FactoryGirl.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :status, { :id => host.to_param }
    assert_response :success
  end

  test "should not allow access to a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not list a host out of users hosts scope" do
    host = FactoryGirl.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :index, {}
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    ids = hosts['results'].map { |hash| hash['id'] }
    refute_includes ids, @host.id
    assert_includes ids, host.id
  end

  test "should not update host out of users hosts scope" do
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not delete hosts out of users hosts scope" do
    setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    delete :destroy, { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not show status of hosts out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, { :id => @host.to_param }
    assert_response :not_found
  end

  test "should show hosts vm attributes" do
    host = FactoryGirl.create(:host, :compute_resource => compute_resources(:one))
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns(:cpus => 4)
    get :vm_compute_attributes, { :id => host.to_param }
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
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response :success
    get :show, {:id => host.to_param}
    assert_response :success
  end

  test "should disassociate host" do
    host = FactoryGirl.create(:host, :on_compute_resource)
    assert host.compute?
    put :disassociate, { :id => host.to_param }
    assert_response :success
    refute host.reload.compute?
  end

  def fact_json
    @json ||= read_json_fixture('facts/brslc022.facts.json')
  end

  test "should run puppet for specific host" do
    as_admin { @phost = FactoryGirl.create(:host, :with_puppet) }
    User.current=nil
    ProxyAPI::Puppet.any_instance.stubs(:run).returns(true)
    put :puppetrun, { :id => @phost.to_param }
    assert_response :success
  end

  def test_rebuild_config_optimistic
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => true, "DNS" => true, "DHCP" => true })
    host = FactoryGirl.create(:host)
    post :rebuild_config, { :id => host.to_param }, set_session_user
    assert_response :success
  end

  def test_rebuild_config_pessimistic
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => false, "DNS" => false, "DHCP" => false })
    host = FactoryGirl.create(:host)
    post :rebuild_config, { :id => host.to_param }, set_session_user
    assert_response 422
  end

  def test_rebuild_tftp_config
    Host.any_instance.expects(:recreate_config).returns({ "TFTP" => true })
    host = FactoryGirl.create(:host)
    post :rebuild_config, { :id => host.to_param, :only => ['TFTP'] }, set_session_user
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_without_certname
    User.current=nil
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}, set_session_user
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_with_certname
    User.current=nil
    hostname = fact_json['name']
    certname = fact_json['certname']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :certname => certname, :facts => facts}, set_session_user
    assert_response :success
  end

  def test_create_invalid
    User.current=nil
    hostname = fact_json['name']
    facts    = fact_json['facts'].except('operatingsystem')
    post :facts, {:name => hostname, :facts => facts}, set_session_user
    assert_response :unprocessable_entity
  end

  test 'set hostgroup when foreman_hostgroup present in facts' do
    Setting[:create_new_host_when_facts_are_uploaded] = true
    hostgroup = FactoryGirl.create(:hostgroup)
    hostname = fact_json['name']
    facts    = fact_json['facts']
    facts['foreman_hostgroup'] = hostgroup.title
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
    assert_equal hostgroup, Host.find_by(:name => hostname).hostgroup
  end

  test 'assign hostgroup attributes when foreman_hostgroup present in facts' do
    Setting[:create_new_host_when_facts_are_uploaded] = true
    hostgroup = FactoryGirl.create(:hostgroup, :with_rootpass)
    hostname = fact_json['name']
    facts    = fact_json['facts']
    facts['foreman_hostgroup'] = hostgroup.title
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
    assert_equal hostgroup.root_pass, Host.find_by(:name => hostname).root_pass
  end

  test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_nil @controller.detected_proxy
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = false

    proxy = smart_proxies(:puppetmaster)
    host = URI.parse(proxy.url).host
    Resolv.any_instance.stubs(:getnames).returns([host])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_equal proxy, @controller.detected_proxy
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'hosts with a registered smart proxy and SSL cert should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
  end

  test 'hosts without a registered smart proxy but with an SSL cert should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'hosts with an unverified SSL cert should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=secure.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_smart_proxies" and "require_ssl" are true, HTTP requests should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_smart_proxies" is true and "require_ssl" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    # since require_ssl_smart_proxies is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
  end

  test "when a bad :type is requested, :unprocessable_entity is returned" do
    User.current=nil
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts, :type => "Host::Invalid"}, set_session_user
    assert_response :unprocessable_entity
    assert JSON.parse(response.body)['message'] =~ /ERF42-3624/
  end

  test "when the imported host failed to save, :unprocessable_entity is returned" do
    Host::Managed.any_instance.stubs(:save).returns(false)
    Nic::Managed.any_instance.stubs(:save).returns(false)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :foo, 'A stub failure'
    Host::Managed.any_instance.stubs(:errors).returns(errors)
    User.current=nil
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}, set_session_user
    assert_response :unprocessable_entity
    assert_equal 'A stub failure', JSON.parse(response.body)['error']['errors']['foo'].first
  end

  test 'non-admin user with power_host permission can boot a vm' do
    @bmchost = FactoryGirl.create(:host, :managed)
    FactoryGirl.create(:nic_bmc, :host => @bmchost)
    ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
    role = FactoryGirl.create(:role, :name => 'power_hosts')
    role.add_permissions!(['power_hosts'])
    api_user = FactoryGirl.create(:user)
    api_user.update_attribute :roles, [role]
    as_user(api_user) do
      put :power, { :id => @bmchost.to_param, :power_action => 'status' }
    end
    assert_response :success
    assert @response.body =~ /on/
  end

  context 'BMC proxy operations' do
    setup :initialize_proxy_ops

    def initialize_proxy_ops
      User.current = users(:apiadmin)
      @bmchost = FactoryGirl.create(:host, :managed)
      FactoryGirl.create(:nic_bmc, :host => @bmchost)
    end

    test "power call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
      put :power, { :id => @bmchost.to_param, :power_action => 'status' }
      assert_response :success
      assert @response.body =~ /on/
    end

    test "wrong power call fails gracefully" do
      put :power, { :id => @bmchost.to_param, :power_action => 'wrongmethod' }
      assert_response 422
      assert @response.body =~ /available methods are/
    end

    test "boot call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:boot).with(:function => 'bootdevice', :device => 'bios').
                                              returns({ "action" => "bios", "result" => true } .to_json)
      put :boot, { :id => @bmchost.to_param, :device => 'bios' }
      assert_response :success
      assert @response.body =~ /true/
    end

    test "wrong boot call to interface fails gracefully" do
      put :boot, { :id => @bmchost.to_param, :device => 'wrongbootdevice' }
      assert_response 422
      assert @response.body =~ /available devices are/
    end

    context 'permissions' do
      setup do
        setup_user 'view', 'hosts'
        setup_user 'ipmi_boot', 'hosts'
      end

      test 'returns error for non-admin user if BMC is not available' do
        put :boot, { :id => @host.to_param, :device => 'bios'},
          set_session_user.merge(:user => @one.id)
        assert_match(/No BMC NIC available/, response.body)
        assert_response :unprocessable_entity
      end

      test 'responds correctly for non-admin user if BMC is available' do
        ProxyAPI::BMC.any_instance.stubs(:boot).
          with(:function => 'bootdevice', :device => 'bios').
          returns({ "action" => "bios", "result" => true } .to_json)
        put :boot, { :id => @bmchost.to_param, :device => 'bios'},
          set_session_user.merge(:user => @one.id)
        assert_response :success
      end
    end

    test "should return correct total and subtotal metadata if search param is passed" do
      FactoryGirl.create_list(:host, 8)
      get :index, {:search => @bmchost.name }
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 10, response['total'] # one from setup, one from bmc setup, 8 here
      assert_equal 1, response['subtotal']
      assert_equal @bmchost.name, response['search']
    end
  end

  test 'template should return rendered template' do
    managed_host = FactoryGirl.create(:host, :managed)
    Host::Managed.any_instance.stubs(:provisioning_template).with({:kind => 'provision'}).returns(FactoryGirl.create(:provisioning_template))
    get :template, { :id => managed_host.to_param, :kind => 'provision' }
    assert_response :success
    assert @response.body =~ /template content/
  end

  test 'wrong template name should return not found' do
    managed_host = FactoryGirl.create(:host, :managed)
    Host::Managed.any_instance.stubs(:provisioning_template).with({:kind => 'provitamin'}).returns(nil)
    get :template, { :id => managed_host.to_param, :kind => 'provitamin' }
    assert_response :not_found
  end

  context 'search by hostgroup' do
    def setup
      @hostgroup = FactoryGirl.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @managed_host = FactoryGirl.create(:host, :managed, :hostgroup => @hostgroup)
    end

    test "should search host by hostgroup name" do
      get :index, { :search => "hostgroup_name = #{@hostgroup.name}" }
      assert_equal [@managed_host], assigns(:hosts)
    end

    test "should search host by hostgroup title" do
      get :index, { :search => "hostgroup_title = #{@hostgroup.title}" }
      assert_equal [@managed_host], assigns(:hosts)
    end
  end

  test "user without view_params permission can't see host parameters" do
    setup_user "view", "hosts"
    host_with_parameter = FactoryGirl.create(:host, :with_parameter)
    get :show, {:id => host_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see host parameters" do
    setup_user "view", "hosts"
    setup_user "view", "params"
    host_with_parameter = FactoryGirl.create(:host, :with_parameter)
    get :show, {:id => host_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  test "should get ENC values of host" do
    host = FactoryGirl.create(:host, :with_puppetclass)
    get :enc, { :id => host.to_param }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    puppet_class = response['data']['classes'].first rescue nil
    assert_equal host.puppetclasses.first.name, puppet_class
  end

  context 'hidden parameters' do
    test "should show a host parameter as hidden unless show_hidden_parameters is true" do
      host = FactoryGirl.create(:host)
      host.host_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, { :id => host.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a host parameter as unhidden when show_hidden_parameters is true" do
      host = FactoryGirl.create(:host)
      host.host_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, { :id => host.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing host parameters" do
    host = FactoryGirl.create(:host, :with_parameter)
    host_param = host.parameters.first
    put :update, { :id => host.id, :host => { :host_parameters_attributes => [{ :name => host_param.name, :value => "new_value" }] } }
    assert_response :success
  end

  private

  def last_record
    Host.unscoped.order(:id).last
  end

  test "host with two interfaces should get ips assigned on both interfaces" do
    disable_orchestration
    subnet1 = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet1', :network => '192.168.2.0', :from => '192.168.2.10',
                                  :to => '192.168.2.12', :dns_primary => '192.168.2.2', :gateway => '192.168.2.3',
                                  :ipam => IPAM::MODES[:db], :location_ids => [ basic_attrs[:location_id] ],
                                  :organization_ids => [ basic_attrs[:organization_id] ])
    subnet2 = FactoryGirl.create(:subnet_ipv4, :name => 'my_subnet2', :network => '192.168.3.0', :from => '192.168.3.10',
                                 :to => '192.168.3.12', :dns_primary => '192.168.3.2', :gateway => '192.168.3.3',
                                 :ipam => IPAM::MODES[:db], :location_ids => [ basic_attrs[:location_id] ],
                                 :organization_ids => [ basic_attrs[:organization_id] ])
    assert_difference('Host.count') do
      post :create, { :host => basic_attrs.merge!(:interfaces_attributes => [{ :primary => true, :mac => '00:11:22:33:44:00',
                      :subnet_id => subnet1.id}, { :primary => false, :mac => '00:11:22:33:44:01', :subnet_id => subnet2.id}]) }
    end
    assert_response :created
    assert_equal 2, last_record.interfaces.count
    assert_equal '192.168.2.10', last_record.interfaces.find_by_mac('00:11:22:33:44:00').ip
    assert_equal '192.168.3.10', last_record.interfaces.find_by_mac('00:11:22:33:44:01').ip
  end
end
