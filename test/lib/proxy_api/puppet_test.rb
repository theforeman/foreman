require 'test_helper'

class ProxyApiPuppetTest < ActiveSupport::TestCase
  def setup
    @url = "http://localhost:8443"
    @puppet = ProxyAPI::Puppet.new({:url => @url})
  end

  test "constructor should complete" do
    @puppet.stubs(:get).raises(RestClient::ResourceNotFound, 'Resource Not Found')
    response = @puppet.classes('production')
    empty_hash = Hash.new
    assert_equal(response, empty_hash)
  end
end