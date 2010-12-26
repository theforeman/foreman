require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  def test_should_be_valid
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url  = "https://secure.proxy:4568"
    assert proxy.valid?
  end

def test_should_not_be_modified_if_has_no_leading_slashes
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url  = "https://secure.proxy:4568"
    assert proxy.valid?
    assert_equal proxy.url, "https://secure.proxy:4568"
  end


  def test_should_not_include_trailing_slash
    proxy = SmartProxy.new
    proxy.name = "test a proxy"
    proxy.url  = "http://some.proxy:4568/"
    assert proxy.save
    assert_equal proxy.url, "http://some.proxy:4568"
  end
end
