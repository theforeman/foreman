require 'test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase

  def valid_attrs
    { :name                => 'testhost11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ip                  => '10.0.0.20',
      :mac                 => '52:53:00:1e:85:93',
      :ptable_id           => ptables(:one).id,
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:one).id,
      :compute_resource_id => compute_resources(:one).id,
      :root_pass           => "xybxa6JUkz63w"
    }
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
  end

  test "should show individual record" do
    get :show, { :id => hosts(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create host" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, { :host => valid_attrs }
    end
    assert_response :success
    last_host = Host.order('id desc').last
  end

  test "should create host with managed is false if parameter is passed" do
    disable_orchestration
    post :create, { :host => valid_attrs.merge!(:managed => false) }
    assert_response :success
    last_host = Host.order('id desc').last
    assert_equal false, last_host.managed?
  end

  test "should update host" do
    put :update, { :id => hosts(:two).to_param, :host => { } }
    assert_response :success
  end

  test "should destroy hosts" do
    assert_difference('Host.count', -1) do
      delete :destroy, { :id => hosts(:one).to_param }
    end
    assert_response :success
  end

  test "should show status hosts" do
    get :status, { :id => hosts(:one).to_param }
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
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, { :id => hosts(:owned_by_restricted).to_param }
    assert_response :success
  end

  test "should allow to update for restricted user who owns the host" do
    disable_orchestration
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, { :id => hosts(:owned_by_restricted).to_param, :host => {} }
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the hosts" do
    assert_difference('Host.count', -1) do
      setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
      delete :destroy, { :id => hosts(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the hosts" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, { :id => hosts(:owned_by_restricted).to_param }
    assert_response :success
  end

  test "should not allow access to a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not list a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :index, {}
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    ids = hosts['results'].map { |hash| hash['id'] }
    refute_includes ids, hosts(:one).id
    assert_includes ids, hosts(:owned_by_restricted).id
  end

  test "should not update host out of users hosts scope" do
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not delete hosts out of users hosts scope" do
    setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    delete :destroy, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not show status of hosts out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  def set_remote_user_to user
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

  def fact_json
    @json  ||= JSON.parse(Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.json").read)
  end

  test "should run puppet for specific host" do
    User.current=nil
    ProxyAPI::Puppet.any_instance.stubs(:run).returns(true)
    put :puppetrun, { :id => hosts(:one).to_param }
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

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = false
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
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    proxy = smart_proxies(:puppetmaster)
    host   = URI.parse(proxy.url).host
    Resolv.any_instance.stubs(:getnames).returns([host])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_equal proxy, @controller.detected_proxy
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'hosts with a registered smart proxy and SSL cert should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

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
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

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
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=secure.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
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
    assert JSON.parse(response.body)['message'] =~ /ERF42-2640/
  end

  test "when the imported host failed to save, :unprocessable_entity is returned" do
    Host::Managed.any_instance.stubs(:save).returns(false)
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

  context 'BMC proxy operations' do
    setup :initialize_proxy_ops

    def initialize_proxy_ops
      User.current = users(:apiadmin)
      nics(:bmc).update_attribute(:host_id, hosts(:one).id)
    end

    test "power call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
      put :power, { :id => hosts(:one).to_param, :power_action => 'status' }
      assert_response :success
      assert @response.body =~ /on/
    end

    test "wrong power call fails gracefully" do
      put :power, { :id => hosts(:one).to_param, :power_action => 'wrongmethod' }
      assert_response 422
      assert @response.body =~ /Available methods are/
    end

    test "boot call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:boot).with(:function => 'bootdevice', :device => 'bios').
                                              returns( { "action" => "bios", "result" => true } .to_json)
      put :boot, { :id => hosts(:one).to_param, :device => 'bios' }
      assert_response :success
      assert @response.body =~ /true/
    end

    test "wrong boot call to interface fails gracefully" do
      put :boot, { :id => hosts(:one).to_param, :device => 'wrongbootdevice' }
      assert_response 422
      assert @response.body =~ /Available devices are/
    end

    test "should return correct total and subtotal metadata if search param is passed" do
      get :index, {:search => 'my5name.mydomain.net' }
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 16, response['total']
      assert_equal  1, response['subtotal']
      assert_equal 'my5name.mydomain.net', response['search']
    end

  end

end
