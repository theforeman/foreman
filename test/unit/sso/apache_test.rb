require 'test_helper'

class ApacheTest < ActiveSupport::TestCase
  def test_user_is_set_when_authenticated
    apache = get_apache_method
    assert apache.authenticated?
    assert_equal apache.user, 'ares'
  end

  def test_available?
    # non api request
    apache = get_apache_method(false)
    Setting["authorize_login_delegation"] = true
    assert apache.available?

    Setting["authorize_login_delegation"] = false
    assert !apache.available?

    Setting["authorize_login_delegation"] = true
    # api request
    apache = get_apache_method(true)
    Setting["authorize_login_delegation_api"] = true
    assert apache.available?

    Setting["authorize_login_delegation_api"] = false
    assert !apache.available?
  end

  def get_apache_method(api_request = false)
    SSO::Apache.new(get_controller(api_request))
  end

  def get_controller(api_request)
    controller = Struct.new(:request).new(Struct.new(:env).new({ 'REMOTE_USER' => 'ares' }))
    stub(controller).api_request? { api_request }
    controller
  end
end