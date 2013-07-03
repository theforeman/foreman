require 'test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  def fact_json
    @json  ||= JSON.parse(Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.json").read)
  end

  fixtures

  test "should run puppet for specific host" do
    User.current=nil
    any_instance_of(ProxyAPI::Puppet) do |klass|
      stub(klass).run { true }
    end
    get :puppetrun, { :id => hosts(:one).to_param }
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
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
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
    assert_equal JSON.parse(response.body)['message'], 'ERF51-2640: A problem occurred when detecting host type: uninitialized constant Host::Invalid'
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
    assert_equal 'A stub failure', JSON.parse(response.body)['host']['errors']['foo'].first
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

  end

end
