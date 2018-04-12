require 'test_helper'

class ProxyApiPuppetTest < ActiveSupport::TestCase
  def setup
    @url = "http://dummyproxy.theforeman.org:8443"
    @puppet = ProxyAPI::Puppet.new({:url => @url})
  end

  test "should return empty hash incase of empty classes" do
    @puppet.stubs(:get).raises(RestClient::ResourceNotFound, 'Resource Not Found')
    response = @puppet.classes('production')
    empty_hash = {}
    assert_equal(empty_hash, response)
  end
end
