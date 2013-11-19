require 'test_helper'

class SignoTest < ActiveSupport::TestCase
  def test_casual_request_authenticated?
    assert !get_signo_method.authenticated?
  end

  def test_openid_request_authenticated?
    controller = get_controller
    controller.request.stubs(:env).returns({ Rack::OpenID::RESPONSE => {} })
    signo = get_signo_method(controller)

    signo.stubs(:parse_open_id).returns(false)
    assert !signo.authenticated?

    signo.stubs(:parse_open_id).returns(true)
    assert signo.authenticated?
    assert_equal signo.session[:sso_method], 'SSO::Signo'
  end

  def test_parse_open_id_success
    signo    = get_signo_method
    response = Object.new
    response.stubs(:status).returns(:success)
    response.stubs(:identity_url).returns('https://localsystem/user/ares')
    assert signo.send(:parse_open_id, response)
    assert_equal signo.user, 'ares'
  end

  def test_parse_open_id_fail
    signo    = get_signo_method
    response = Object.new
    response.stubs(:status).returns(:fail)
    assert !signo.send(:parse_open_id, response)
  end

  def test_authenticate_without_cookie
    controller = get_controller
    controller.request.stubs(:params).returns({})
    controller.request.stubs(:url).returns('https://localsystem/foreman?a=b&c=d')
    url   = Setting['signo_url'] + "?return_url=#{URI.escape('https://localsystem/foreman?a=b&c=d')}"
    Setting['signo_sso'] = true
    controller.send(:extend, Foreman::Controller::Authentication)
    controller.stubs(:api_request?).returns(false)
    controller.request.stubs(:authorization).returns({})
    controller.request.stubs(:fullpath).returns({})
    controller.expects(:redirect_to).with(url).once
    controller.authenticate
  end

  def test_authenticate_with_cookie
    controller = get_controller
    controller.stubs(:render).returns('correct render')
    controller.request.stubs(:cookies).returns({'username' => 'ares'})
    signo    = get_signo_method(controller)
    response = signo.authenticate!

    assert_equal response, 'correct render'
    assert signo.headers.keys.include?('WWW-Authenticate')
    assert signo.headers['WWW-Authenticate'].include?('/user/ares')
  end

  def test_authenticate_with_username
    controller = get_controller
    controller.request.stubs(:cookies).returns({})
    controller.request.stubs(:params).returns({:username => 'ares'})
    controller.stubs(:render).returns('correct render')
    signo    = get_signo_method(controller)
    response = signo.authenticate!

    assert_equal response, 'correct render'
    assert signo.headers.keys.include?('WWW-Authenticate')
    assert signo.headers['WWW-Authenticate'].include?('/user/ares')
  end

  def get_signo_method(controller = nil)
    SSO::Signo.new(controller || get_controller)
  end

  def get_controller
    request    = Object.new
    controller = Object.new

    # we must create and save hash object reference otherwise we'll create new empty hash
    # with every method call, hence Hash.new lines
    req = Hash.new
    request.stubs(:env).returns(req)
    cookies = Hash.new
    request.stubs(:cookies).returns(cookies)
    request.stubs(:url).returns('https://localsystem/wherever/am?i=whoever&am=i')
    headers = Hash.new
    controller.stubs(:headers).returns(headers)
    controller.stubs(:request).returns(request)
    session = Hash.new
    controller.stubs(:session).returns(session)
    controller.stubs(:root_url).returns('https://localsystem/foreman?a=b&c=d')

    controller
  end
end
