require 'test_helper'

class SignoTest < ActiveSupport::TestCase
  def test_casual_request_authenticated?
    assert !get_signo_method.authenticated?
  end

  def test_openid_request_authenticated?
    controller = get_controller
    stub(controller.request).env { { Rack::OpenID::RESPONSE => {} } }
    signo = get_signo_method(controller)

    stub(signo).parse_open_id { false }
    assert !signo.authenticated?

    stub(signo).parse_open_id { true }
    assert signo.authenticated?
    assert_equal signo.session[:sso_method], 'SSO::Signo'
  end

  def test_parse_open_id_success
    signo    = get_signo_method
    response = Object.new
    stub(response).status { :success }
    stub(response).identity_url { 'https://localhost/user/ares' }
    assert signo.send(:parse_open_id, response)
    assert_equal signo.user, 'ares'
  end

  def test_parse_open_id_fail
    signo    = get_signo_method
    response = Object.new
    stub(response).status { :fail }
    assert !signo.send(:parse_open_id, response)
  end

  def test_authenticate_without_cookie
    controller = get_controller
    stub(controller.request).params { { } }
    stub(controller.request).url { 'https://localhost/foreman?a=b&c=d' }
    signo = get_signo_method(controller)
    url   = Setting['signo_url'] + "?return_url=#{URI.escape('https://localhost/foreman?a=b&c=d')}"
    mock(controller).redirect_to(url) { 'correct redirect' }
    assert_equal signo.authenticate!, 'correct redirect'
  end

  def test_authenticate_with_cookie
    controller = get_controller
    stub(controller.request).cookies { { 'username' => 'ares' } }
    stub(controller).render { 'correct render' }
    signo    = get_signo_method(controller)
    response = signo.authenticate!

    assert_equal response, 'correct render'
    assert signo.headers.keys.include?('WWW-Authenticate')
    assert signo.headers['WWW-Authenticate'].include?('/user/ares')
  end

  def test_authenticate_with_username
    controller = get_controller
    stub(controller.request).cookies { { } }
    stub(controller.request).params { { :username => 'ares' } }
    stub(controller).render { 'correct render' }
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
    stub(request).env { req }
    cookies = Hash.new
    stub(request).cookies { cookies }
    stub(request).url { 'https://localhost/wherever/am?i=whoever&am=i' }
    headers = Hash.new
    stub(controller).headers { headers }
    stub(controller).request { request }
    session = Hash.new
    stub(controller).session { session }
    stub(controller).root_url { 'https://localhost/foreman?a=b&c=d' }

    controller
  end
end
