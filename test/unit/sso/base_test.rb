require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  def test_assigns
    controller = get_controller
    base = SSO::Base.new(controller)
    assert_equal base.controller, controller
    assert_equal base.request, 'request'
  end

  def test_user
    controller = get_controller
    base = SSO::Base.new(controller)
    base.expects(:user).returns(users(:one).login)
    assert_kind_of User, base.current_user
  end

  def test_user_not_hidden
    controller = get_controller
    base = SSO::Base.new(controller)
    base.expects(:user).returns(User::ANONYMOUS_ADMIN)
    refute base.current_user
  end

  def get_controller
    Struct.new(:request).new('request')
  end
end
