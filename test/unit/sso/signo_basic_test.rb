require 'test_helper'

class SignoBasicTest < ActiveSupport::TestCase
  def setup
    Setting['signo_sso'] = true
  end

  def teardown
    Setting['signo_sso'] = false
  end

  test 'http signo basic available in good conditions' do
    basic = SSO::SignoBasic.new(get_basic_controller(true))
    assert basic.available?
  end

  test 'http signo basic not available for non api requests' do
    basic = SSO::SignoBasic.new(get_basic_controller(false))
    assert !basic.available?
  end

  test 'http signo basic is skipped if Signo is disabled' do
    Setting['signo_sso'] = false
    basic = SSO::SignoBasic.new(get_basic_controller(true))
    assert !basic.available?
  end

  test 'authenticates if user.current is not set' do
    User.current = nil
    basic = SSO::SignoBasic.new(get_basic_controller(true))
    basic.stubs(:signo_auth).returns( users(:one) )
    assert_equal users(:one).login, basic.authenticated?
  end

  test 'does not reauthenticate if user.current is set' do
    User.current = users(:one)
    basic = SSO::SignoBasic.new(get_basic_controller(true))
    basic.stubs(:signo_auth).returns( users(:one) )
    assert_equal users(:one).login, basic.authenticated?
  end

  def get_basic_controller(api_request)
    controller = Struct.new(:request).new(Struct.new(:authorization).new('Basic'))
    controller.stubs(:api_request?).returns(api_request)
    controller
  end
end
