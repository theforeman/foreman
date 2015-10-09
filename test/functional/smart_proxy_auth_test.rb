require 'test_helper'

class SmartProxyAuthApiTest < ActionController::TestCase
  tests "api/v2/reports"

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
      @controller.send(:require_smart_proxy_or_login, Proc.new { raise ArgumentError, 'test' } )
    end
  end

  def test_certificate_with_dn_permits_access
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=proxy.example.com,DN=example,DN=com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    CertificateExtract.expects(:new).never

    proxy = FactoryGirl.create(:smart_proxy, :url => 'https://proxy.example.com:8443')
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

    proxy = FactoryGirl.create(:smart_proxy, :url => 'https://san2.example.com:8443')
    assert @controller.send(:auth_smart_proxy)
    assert_equal proxy, @controller.detected_proxy
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

    get :externalNodes, :id => 123

    assert_response :forbidden
    assert_template "common/403"
  end
end
