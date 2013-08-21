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
    as_admin do
      assert proxy.save
    end
    assert_equal proxy.url, "http://some.proxy:4568"
  end

  def test_should_honor_legacy_puppet_hostname_true_setting
    Setting[:legacy_puppet_hostname] = true
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url = "http://puppet.example.com:4568"

    assert_equal proxy.to_s, "puppet"
  end

  def test_should_honor_legacy_puppet_hostname_false_setting
    Setting[:legacy_puppet_hostname] = false
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url = "http://puppet.example.com:4568"

    assert_equal proxy.to_s, "puppet.example.com"
  end
end
