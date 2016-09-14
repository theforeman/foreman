require 'test_helper'

class ProxyApiDhcpTest < ActiveSupport::TestCase
  def setup
    @url = "http://localhost:8443"
    @dhcp = ProxyAPI::DHCP.new({:url => @url})
  end

  test "constructor should complete" do
    assert_not_nil(@dhcp)
  end

  test "base url should equal /dhcp" do
    expected = "#{@url}/dhcp"
    assert_equal(expected, @dhcp.url)
  end

  test "unused_ip should get an IP using only the network address" do
    subnet_mock = mock('subnet')
    subnet_mock.expects(:network).returns('192.168.0.0')
    subnet_mock.expects(:from).returns(nil)

    @dhcp.expects(:get).with('192.168.0.0/unused_ip').returns(fake_rest_client_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet_mock))
  end

  test "unused_ip should get an IP using the network, from and to addresses" do
    from_mock = mock('from')
    from_mock.expects(:to_s).returns('192.168.0.50')
    from_mock.expects(:present?).returns(true)
    to_mock = mock('to')
    to_mock.expects(:to_s).returns('192.168.0.150')
    to_mock.expects(:present?).returns(true)
    subnet_mock = mock('subnet')
    subnet_mock.expects(:network).at_least_once.returns('192.168.0.0')
    subnet_mock.expects(:from).at_least_once.returns(from_mock)
    subnet_mock.expects(:to).at_least_once.returns(to_mock)

    @dhcp.expects(:get).with() do |path|
      # Params built with a hash, so order can change
      path.include?('192.168.0.0/unused_ip?') &&
        path.include?('from=192.168.0.50') &&
        path.include?('to=192.168.0.150')
    end.returns(fake_rest_client_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet_mock))
  end

  test "unused_ip should get an IP using the network and MAC address" do
    subnet_mock = mock()
    subnet_mock.expects(:network).returns('192.168.0.0')
    subnet_mock.expects(:from).returns(nil)

    @dhcp.expects(:get).with('192.168.0.0/unused_ip?mac=00:11:22:33:44:55').returns(fake_rest_client_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet_mock, '00:11:22:33:44:55'))
  end
end
