require 'test_helper'

class SignoTest < ActiveSupport::TestCase
  def test_logout_path_can_be_appended
    assert_equal get_signo_method.logout_path.last, '='
  end

  def test_casual_request_authenticated?
    refute get_signo_method.authenticated?
  end

  def test_openid_request_authenticated?
    controller = get_controller
    stub(controller.request).env { { Rack::OpenID::RESPONSE => {} } }
    signo = get_signo_method(controller)

    stub(signo).parse_open_id { false }
    refute signo.authenticated?

    stub(signo).parse_open_id { true }
    assert signo.authenticated?
  end

  def test_parse_open_id_success
    signo = get_signo_method
    response = Object.new
    stub(response).status { :success }
    stub(response).identity_url { 'https://localhost/user/ares' }
    assert signo.send(:parse_open_id, response)
    assert_equal signo.user, 'ares'
  end

  def test_parse_open_id_fail
    signo = get_signo_method
    response = Object.new
    stub(response).status { :fail }
    refute signo.send(:parse_open_id, response)
  end

  def test_authenticate_without_cookie
    controller = get_controller
    stub(controller.request).url {'https://localhost/foreman?a=b&c=d'}
    signo = get_signo_method(controller)
    url = Setting['signo_url'] + "?return_url=#{URI.escape('https://localhost/foreman?a=b&c=d')}"
    mock(controller).redirect_to(url) { 'correct redirect' }
    assert_equal signo.authenticate!, 'correct redirect'
  end

  def test_authenticate_with_cookie
    controller = get_controller
    stub(controller.request).cookies { {'username' => 'ares'} }
    stub(controller).render { 'correct render' }
    signo = get_signo_method(controller)
    response = signo.authenticate!

    assert_equal response, 'correct render'
    assert signo.headers.keys.include?('WWW-Authenticate')
    assert signo.headers['WWW-Authenticate'].include?('/user/ares')
  end

  def get_signo_method(controller = nil)
    Sso::Signo.new(controller || get_controller)
  end

  def get_controller
    request    = Object.new
    controller = Object.new
    stub(request).env { {} }
    stub(request).cookies { {} }
    stub(controller).headers { {} }
    stub(controller).request { request }
    controller
  end
end