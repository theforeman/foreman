require 'test_helper'

class ProxyApiDhcpTest < ActiveSupport::TestCase
  let(:url) { 'http://dummyproxy.theforeman.org:8443' }
  let(:proxy_dhcp) { ProxyAPI::DHCP.new(:url => url) }

  test "constructor should complete" do
    assert_not_nil(proxy_dhcp)
  end

  test "base url should equal /dhcp" do
    expected = "#{url}/dhcp"
    assert_equal(expected, proxy_dhcp.url)
  end

  context 'record retrieval' do
    let(:fake_response) do
      {
        'name' => 'www.example.com',
        'mac' => '00:11:22:33:44:55',
        'ip' => '192.168.0.10',
        'filename' => 'pxelinux.0',
        'nextServer' => '1.2.3.4',
        'hostname' => 'www.example.com',
        'subnet' => '192.168.0.0/255.255.255.0',
      }
    end

    describe '#record' do
      setup do
        proxy_dhcp.stubs(:get).with('192.168.0.0/mac/192.168.0.10').returns(fake_rest_client_response(fake_response))
      end

      test 'retrieves an array with a single dhcp record' do
        result = proxy_dhcp.record('192.168.0.0', '192.168.0.10')
        assert_kind_of Net::DHCP::Record, result
        assert_equal({:hostname => "www.example.com",
                      :mac => "00:11:22:33:44:55",
                      :ip => "192.168.0.10",
                      :network => "192.168.0.0",
                      :nextServer => "1.2.3.4",
                      :filename => "pxelinux.0",
                      :name => "www.example.com",
                      :related_macs => []}, result.attrs)
      end
    end

    describe '#records_by_ip' do
      setup do
        proxy_dhcp.stubs(:get).with('192.168.0.0/ip/192.168.0.10').returns(fake_rest_client_response([fake_response]))
      end

      test 'retrieves an array with a single dhcp record' do
        result = proxy_dhcp.records_by_ip('192.168.0.0', '192.168.0.10')
        assert_kind_of Array, result
        assert_kind_of Net::DHCP::Record, result.first
        assert_equal({:hostname => "www.example.com",
                      :mac => "00:11:22:33:44:55",
                      :ip => "192.168.0.10",
                      :network => "192.168.0.0",
                      :nextServer => "1.2.3.4",
                      :filename => "pxelinux.0",
                      :name => "www.example.com",
                      :related_macs => []}, result.first.attrs)
      end
    end
  end

  test "unused_ip should get an IP using only the network address" do
    subnet_mock = mock('subnet')
    subnet_mock.expects(:network).returns('192.168.0.0')
    subnet_mock.expects(:from).returns(nil)

    proxy_dhcp.expects(:get).with('192.168.0.0/unused_ip', {query: ""}).returns(fake_rest_client_response({:ip => '192.168.0.50'}))
    assert_equal({'ip' => '192.168.0.50'}, proxy_dhcp.unused_ip(subnet_mock))
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

    proxy_dhcp.expects(:get).with("192.168.0.0/unused_ip", { query: "from=192.168.0.50&to=192.168.0.150"}).returns(fake_rest_client_response({:ip => '192.168.0.50'}))
    assert_equal({'ip' => '192.168.0.50'}, proxy_dhcp.unused_ip(subnet_mock))
  end

  test "unused_ip should get an IP using the network and MAC address" do
    subnet_mock = mock()
    subnet_mock.expects(:network).returns('192.168.0.0')
    subnet_mock.expects(:from).returns(nil)

    proxy_dhcp.expects(:get).with('192.168.0.0/unused_ip', { query: "mac=00:11:22:33:44:55"}).returns(fake_rest_client_response({:ip => '192.168.0.50'}))
    assert_equal({'ip' => '192.168.0.50'}, proxy_dhcp.unused_ip(subnet_mock, '00:11:22:33:44:55'))
  end
end
