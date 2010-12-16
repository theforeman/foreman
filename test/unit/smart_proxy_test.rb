require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  def test_should_be_valid
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url  = "https://secure.proxy:4568"
    assert proxy.valid?
  end
end
