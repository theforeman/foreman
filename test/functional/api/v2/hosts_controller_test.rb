require 'test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  def fact_json
    @json  ||= JSON.parse(Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.json").read)
  end

  def setup
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:internal).login, "secret")
  end

  def use_apiadmin
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:apiadmin).login, "secret")
  end

  test "should run puppet for specific host" do
    use_apiadmin

    any_instance_of(ProxyAPI::Puppet) do |klass|
      stub(klass).run { true }
    end
    get :puppetrun, { :id => hosts(:one).to_param }
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_without_certname
    use_apiadmin

    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_with_certname
    use_apiadmin

    hostname = fact_json['name']
    certname = fact_json['certname']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :certname => certname, :facts => facts}
    assert_response :success
  end

  def test_create_invalid
    use_apiadmin

    hostname = fact_json['name']
    facts    = fact_json['facts'].except('operatingsystem')
    post :facts, {:name => hostname, :facts => facts}
    assert_response :unprocessable_entity
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should import facts successfully' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :forbidden
  end

  test 'hosts with a registered smart proxy and SSL cert should import facts successfully' do
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
    use_apiadmin

    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts, :type => "Host::Invalid"}
    assert_response :unprocessable_entity
    assert_equal JSON.parse(response.body)['message'], 'ERF51-2640: A problem occurred when detecting host type: uninitialized constant Host::Invalid'
  end

  test "when the imported host failed to save, :unprocessable_entity is returned" do
    use_apiadmin

    Host::Managed.any_instance.stubs(:save).returns(false)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :foo, 'A stub failure'
    Host::Managed.any_instance.stubs(:errors).returns(errors)

    hostname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => hostname, :facts => facts}
    assert_response :unprocessable_entity
    assert_equal 'A stub failure', JSON.parse(response.body)['host']['errors']['foo'].first
  end

end
