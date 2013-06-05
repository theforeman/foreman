require 'test_helper'

class ProxyApiDhcpTest < ActiveSupport::TestCase
  def setup
    @url = "http://localhost:8443"
    @dhcp = ProxyAPI::DHCP.new({:url => @url})
  end

  def fake_response(data)
    net_http_resp = Net::HTTPResponse.new(1.0, 200, "OK")
    net_http_resp.add_field 'Set-Cookie', 'Monster'
    RestClient::Response.create(JSON(data), net_http_resp, nil)
  end

  test "constructor should complete" do
    assert_not_nil(@dhcp)
  end

  test "base url should equal /dhcp" do
    expected = "#{@url}/dhcp"
    assert_equal(expected, @dhcp.url)
  end

  test "unused_ip should get an IP using only the network address" do
    mock(subnet = Object.new).network { '192.168.0.0' }
    mock(from = Object.new).present? { false }
    mock(subnet).from { from }

    @dhcp.expects(:get).with('192.168.0.0/unused_ip').returns(fake_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet))
  end

  test "unused_ip should get an IP using the network, from and to addresses" do
    mock(subnet = Object.new).network { '192.168.0.0' }
    mock(from = Object.new).present? { true }
    mock(from).to_s { '192.168.0.50' }
    mock(to = Object.new).present? { true }
    mock(to).to_s { '192.168.0.150' }
    mock(subnet).from.returns(from).at_least(1)
    mock(subnet).to.returns(to).at_least(1)

    @dhcp.expects(:get).with() do |path|
      # Params built with a hash, so order can change
      path.include? '192.168.0.0/unused_ip?' and
        path.include? 'from=192.168.0.50' and
        path.include? 'to=192.168.0.150'
    end.returns(fake_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet))
  end

  test "unused_ip should get an IP using the network and MAC address" do
    mock(subnet = Object.new).network { '192.168.0.0' }
    mock(from = Object.new).present? { false }
    mock(subnet).from { from }

    @dhcp.expects(:get).with('192.168.0.0/unused_ip?mac=00:11:22:33:44:55').returns(fake_response({:ip=>'192.168.0.50'}))
    assert_equal({'ip'=>'192.168.0.50'}, @dhcp.unused_ip(subnet, '00:11:22:33:44:55'))
  end

end
