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

    assert @controller.require_puppetmaster_or_login
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
    Setting[:restrict_registered_puppetmasters] = false
    @controller.stubs(:auth_smart_proxy).returns(true)

    assert @controller.require_puppetmaster_or_login
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

    assert @controller.require_puppetmaster_or_login
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
