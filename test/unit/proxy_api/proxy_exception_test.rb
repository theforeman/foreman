require 'test_helper'

class ProxyApiExceptionTest < ActiveSupport::TestCase
  test 'exception response body is added if available' do
    fake_exception = OpenStruct.new(:response => 'useful message from proxy',
                                    :message => 'useful message from proxy',
                                    :code => 400)
    proxy_exception = ProxyAPI::ProxyException.new(
      'fakeurl',
      fake_exception,
      'unable to do something')
    assert_match(
      /ERF.*ProxyException.*unable to do something.*useful message from proxy.*/,
      proxy_exception.message
    )
  end

  test 'does not fail if response body is not available' do
    proxy_exception = ProxyAPI::ProxyException.new('fakeurl',
                                                   NoMethodError.new,
                                                   'unable to do something')
    assert_equal 'fakeurl', proxy_exception.url
    assert_match(/unable to do something.*NoMethodError.*proxy fakeurl/,
      proxy_exception.message)
  end
end
