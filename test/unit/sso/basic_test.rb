require 'test_helper'

class BasicTest < ActiveSupport::TestCase
  test 'http basic available in good conditions' do
    basic = SSO::Basic.new(get_basic_controller(true))
    assert basic.available?
  end

  test 'http basic not available for non api requests' do
    basic = SSO::Basic.new(get_basic_controller(false))
    assert !basic.available?
  end

  test 'authenticates if user.current is not set' do
    User.current = nil
    basic = SSO::Basic.new(get_basic_controller(true))
    assert_equal 'testuser', basic.authenticated?
  end

  test 'does not reauthenticate if user.current is set' do
    as_user(:one) do
      basic = SSO::Basic.new(get_basic_controller(true))
      assert_equal users(:one).login, basic.authenticated?
    end
  end

  def get_basic_controller(api_request)
    controller = Struct.new(:request).new(Struct.new(:authorization).new('Basic'))
    controller.stubs(:api_request?).returns(api_request)
    controller.stubs(:authenticate_with_http_basic).returns(Struct.new(:login).new('testuser'))
    controller
  end
end
