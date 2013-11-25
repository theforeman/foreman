require 'test_helper'

class ApacheTest < ActiveSupport::TestCase
  def setup
    Setting::Auth.load_defaults
  end

  def test_user_is_set_when_authenticated
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    apache = get_apache_method
    assert apache.authenticated?
    assert_equal apache.user, 'ares'
    assert_equal apache.session[:sso_method], 'SSO::Apache'
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


  def test_authenticated?
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    apache = get_apache_method
    apache.controller.request.env[SSO::Apache::CAS_USERNAME] = nil

    assert !apache.authenticated?
    apache.controller.request.env[SSO::Apache::CAS_USERNAME] = 'ares'
    assert apache.authenticated?
  end

  def test_authenticate!
    apache = get_apache_method
    controller = apache.controller
    controller.stubs(:redirect_to).returns('correct redirect')

    response = apache.authenticate!
    assert apache.has_rendered
    assert_equal response, 'correct redirect'
  end

  def test_support_login
    apache = get_apache_method
    controller = apache.controller
    controller.request.fullpath = '/something'

    assert apache.support_login?

    controller.request.fullpath = '/extlogin'
    assert !apache.support_login?
  end

  def get_apache_method(api_request = false)
    SSO::Apache.new(get_controller(api_request))
  end

  def get_controller(api_request)
    main_app = stub
    main_app.stubs(:extlogin_users_path).returns('/extlogin')
    controller = Struct.new(:request, :session, :extlogin_users_path).new(Struct.new(:env, :fullpath).new({ SSO::Apache::CAS_USERNAME => 'ares' }))
    controller.session = {}
    controller.stubs(:api_request?).returns(api_request)
    controller.stubs(:main_app).returns(main_app)
    controller
  end
end
