require 'test_helper'

class BaseTest < ActiveSupport::TestCase
  def test_assigns
    controller = get_controller
    base = Sso::Base.new(controller)
    assert_equal base.controller, controller
    assert_equal base.request, 'request'
  end

  def get_controller
    Struct.new(:request).new('request')
  end
end