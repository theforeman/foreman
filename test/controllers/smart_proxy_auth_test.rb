require 'test_helper'

class SmartProxyAuthApiTest < ActionController::TestCase
  tests "api/v2/config_reports"

  def described_class
    Api::V2::ReportsController
  end

  def test_successful_authentication_with_valid_basic_auth_credentials_in_api_controller
    User.current = users(:admin)

    @controller.stubs(:auth_smart_proxy).returns(false)
    @controller.stubs(:require_login).returns(true)
    @controller.stubs(:authorize).returns(true)

    assert @controller.send(:require_smart_proxy_or_login)
  end

  def test_failed_authentication_with_invalid_basic_auth_credentials_in_api_controller
    User.current = nil

    @controller.stubs(:auth_smart_proxy).returns(false)
    @controller.stubs(:require_login).returns(false)

    post :create

    assert_response :forbidden
    assert_template "api/v2/errors/access_denied"
  end

  def test_successful_smart_proxy_authentication_in_api_controller
    Setting[:restrict_registered_smart_proxies] = false
    @controller.stubs(:auth_smart_proxy).returns(true)

    assert @controller.send(:require_smart_proxy_or_login)
  end

  def test_require_smart_proxy_or_login_accepts_callable_features
    User.current = users(:admin)

    @controller.stubs(:auth_smart_proxy).returns(false)
    @controller.stubs(:require_login).returns(true)
    @controller.stubs(:authorize).returns(true)

    assert_raise ArgumentError, 'test' do
      @controller.send(:require_smart_proxy_or_login, proc { raise ArgumentError, 'test' })
    end
  end

  def test_certificate_with_dn_permits_access
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=proxy.example.com,DN=example,DN=com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    CertificateExtract.expects(:new).never

    proxy = FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
    assert @controller.send(:auth_smart_proxy)
    assert_equal proxy, @controller.detected_proxy
  end

  def test_wild_card_certificates_are_supported
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = '/C=CZ/ST=Czech Republic/L=Brno/O=Ares/CN=*.example.com,DN=example,DN=com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'

    proxy = FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
    assert @controller.send(:auth_smart_proxy)
    assert_equal proxy, @controller.detected_proxy
  end

  def test_wild_card_certificates_matches_correctly
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = '/C=CZ/ST=Czech Republic/L=Brno/O=Ares/CN=*.example.org,DN=example,DN=com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'

    FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
    refute @controller.send(:auth_smart_proxy)
  end

  def test_wild_card_certificates_supports_only_one_wild_card
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=*.*.com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'

    FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
    refute @controller.send(:auth_smart_proxy)
  end

  def test_wild_card_certificates_supports_escapes_dots_correctly
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=*.example.com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'

    FactoryBot.create(:smart_proxy, :url => 'https://proxyXexampleXcom:8443')
    refute @controller.send(:auth_smart_proxy)
  end

  def test_certificate_with_dn_and_empty_san_permits_access
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_CERT'] = 'raw certificate'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'

    mock_cert = mock()
    mock_cert.expects(:subject).at_least_once.returns('proxy.example.com')
    mock_cert.expects(:subject_alternative_names).at_least_once.returns([])
    CertificateExtract.expects(:new).with('raw certificate').returns(mock_cert)

    proxy = FactoryBot.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
    assert @controller.send(:auth_smart_proxy)
    assert_equal proxy, @controller.detected_proxy
  end

  def test_certificate_with_sans_permits_access
    Setting[:ssl_client_cert_env] = 'SSL_CLIENT_CERT'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['SSL_CLIENT_CERT'] = 'raw certificate'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    @request.env['HTTPS'] = 'on'

    mock_cert = mock()
    mock_cert.expects(:subject).at_least_once.returns('subject.example.com')
    mock_cert.expects(:subject_alternative_names).at_least_once.returns(['san1.example.com', 'san2.example.com'])
    CertificateExtract.expects(:new).with('raw certificate').returns(mock_cert)

    proxy = FactoryBot.create(:smart_proxy, :url => 'https://san2.example.com:8443')
    assert @controller.send(:auth_smart_proxy)
    assert_equal proxy, @controller.detected_proxy
  end

  def test_trusted_puppet_master_hosts_by_ipv4_match
    Resolv.any_instance.expects(:getnames).with('127.0.0.2').returns([])
    @request.env['REMOTE_ADDR'] = '127.0.0.2'
    Setting[:trusted_hosts] = ['127.0.0.2']
    assert @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv4_no_match
    @request.env['REMOTE_ADDR'] = '127.0.0.2'
    refute @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv4_subnet_match
    Resolv.any_instance.expects(:getnames).with('10.0.0.1').returns([])
    @request.env['REMOTE_ADDR'] = '10.0.0.1'
    Setting[:trusted_hosts] = ['10.0.0.1/8']
    assert @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv4_subnet_no_match
    Resolv.any_instance.expects(:getnames).with('10.0.0.1').returns([])
    @request.env['REMOTE_ADDR'] = '10.0.0.1'
    Setting[:trusted_hosts] = ['11.0.0.1/8']
    refute @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv6_match
    @request.env['REMOTE_ADDR'] = '::ffff:127.0.0.1'
    Setting[:trusted_hosts] = ['::ffff:127.0.0.1']
    assert @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv6_no_match
    @request.env['REMOTE_ADDR'] = '::ffff:127.0.0.1'
    refute @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv6_subnet_match
    Resolv.any_instance.expects(:getnames).with('2001:db8:beef::1').returns([])
    @request.env['REMOTE_ADDR'] = '2001:db8:beef::1'
    Setting[:trusted_hosts] = ['2001:db8:beef::/48']
    assert @controller.send(:auth_smart_proxy)
  end

  def test_trusted_puppet_master_hosts_by_ipv6_subnet_no_match
    Resolv.any_instance.expects(:getnames).with('2001:db8:beef::1').returns([])
    @request.env['REMOTE_ADDR'] = '2001:db8:beef::1'
    Setting[:trusted_hosts] = ['2001:db8:cafe::/48']
    refute @controller.send(:auth_smart_proxy)
  end
end

class SmartProxyAuthWebUITest < ActionController::TestCase
  tests "hosts"

  def described_class
    HostsController
  end

  def test_successful_authentication_with_valid_basic_auth_credentials_in_web_ui_controller
    User.current = users(:admin)

    @controller.stubs(:auth_smart_proxy).returns(false)
    @controller.stubs(:require_login).returns(true)
    @controller.stubs(:authorize).returns(true)

    assert @controller.send(:require_smart_proxy_or_login)
  end

  def test_failed_authentication_with_invalid_basic_auth_credentials_in_web_ui_controller
    User.current = nil

    @controller.stubs(:auth_smart_proxy).returns(false)
    @controller.stubs(:require_login).returns(false)

    @controller.stubs(:performed?).returns(false)
    @controller.expects(:render_error).with('access_denied', status: :forbidden)

    refute @controller.send(:require_smart_proxy_or_login)
  end
end
