require 'test_helper'

class HTTPProxyTest < ActiveSupport::TestCase
  class DummyHTTPAdapter
    include Foreman::HTTPProxy
  end

  let(:adapter) { DummyHTTPAdapter.new }
  let(:http_proxy) { 'http://dummyproxy.theforeman.org:3218' }
  let(:excepted_hosts) { [] }
  let(:request_host) { 'dummyproxy.theforeman.org' }
  let(:schema) { 'http' }

  setup do
    adapter.stubs(:http_proxy_except_list)
           .returns(excepted_hosts)
    adapter.stubs(:http_proxy)
           .returns(http_proxy)
  end

  describe '#proxy_http_request?' do
    context 'returns true' do
      test 'when a http_proxy is set' do
        assert adapter.proxy_http_request?(nil, request_host, schema)
      end
    end

    context 'returns false' do
      test 'when a host is excepted' do
        excepted_hosts << 'localhost'
        refute adapter.proxy_http_request?(nil, 'localhost', schema)
      end

      test 'when a host matches a wildcard' do
        excepted_hosts << '*.example.com'
        refute adapter.proxy_http_request?(nil, 'www.example.com', schema)
      end

      test 'when a host matches another domain wildcard' do
        excepted_hosts << 'sub.*.example.com'
        refute adapter.proxy_http_request?(nil, 'sub.www.example.com', schema)
        refute adapter.proxy_http_request?(nil, 'sub.sub.example.com', schema)
      end

      test 'when the IP is excepted_hosts' do
        excepted_hosts << '10.0.0.1'
        refute adapter.proxy_http_request?(nil, '10.0.0.1', schema)
      end

      test 'when the IP is excepted_hosts' do
        excepted_hosts << '10.0.0.*'
        refute adapter.proxy_http_request?(nil, "10.0.0.#{[1..254].sample}", schema)
      end

      test 'when no http_proxy is set it' do
        adapter.stubs(:http_proxy).returns(nil)
        refute adapter.proxy_http_request?(nil, request_host, schema)
      end

      test 'when a proxy is already set' do
        refute adapter.proxy_http_request?('http://otherproxy:3128',
          request_host, schema)
      end

      test 'when no request_host is set' do
        refute adapter.proxy_http_request?(nil, nil, schema)
      end

      test 'when the schema is "unix"' do
        refute adapter.proxy_http_request?(nil, request_host, 'unix')
      end

      test 'when settings are nil' do
        adapter.unstub(:http_proxy)
        adapter.unstub(:http_proxy_except_list)
        Setting.stubs(:[]).with(:http_proxy).returns(nil)
        Setting.stubs(:[]).with(:http_proxy_except_list).returns(nil)
        refute adapter.proxy_http_request?(nil, request_host, schema)
      end

      test 'when settings are empty string - after unsetting' do
        adapter.unstub(:http_proxy)
        adapter.unstub(:http_proxy_except_list)
        Setting.stubs(:[]).with(:http_proxy).returns('')
        Setting.stubs(:[]).with(:http_proxy_except_list).returns(nil)
        refute adapter.proxy_http_request?(nil, request_host, schema)
      end

      test 'when request_host is localhost' do
        refute adapter.proxy_http_request?(nil, 'localhost', schema)
      end

      test 'when request_host is fqdn' do
        SETTINGS[:fqdn] = 'test.host.com'
        refute adapter.proxy_http_request?(nil, 'test.host.com', schema)
      end

      test 'when request_host is a loopback address' do
        refute adapter.proxy_http_request?(nil, '127.0.0.1', schema)
      end

      test 'when request_host is a ipv6 local address' do
        refute adapter.proxy_http_request?(nil, '::1', schema)
      end
    end
  end

  describe 'Excon::Connection extension' do
    let(:excon_connection) { Excon::Connection.new }

    setup do
      Excon::Connection.class_eval { prepend Foreman::HttpProxy::ExconConnectionExtension } if Excon::Connection.ancestors.first != Foreman::HttpProxy::ExconConnectionExtension
      excon_connection.stubs(:http_proxy).returns(http_proxy)
      excon_connection.stubs(:setup_proxy).returns
      excon_connection.stubs(:proxy_http_request?).returns(true)
    end

    test 'set @data[:proxy] to proxy' do
      stub_request(:get, "http://#{request_host}/features").to_return(status: 200, body: "", headers: {})
      excon_connection.request({host: request_host, path: "/features", headers: {}})
      assert_equal http_proxy, excon_connection.instance_variable_get(:@data)[:proxy]
    end

    test 'rescues requests and mentions proxy' do
      stub_request(:get, "http://#{request_host}/features").to_raise("AnException")
      assert_raises_with_message Excon::Error::Socket, "AnException" do
        excon_connection.request({host: request_host, path: "/features", headers: {}})
      end
    end
  end

  describe 'Net::HTTP extension' do
    let(:net_http) { Foreman::HttpProxy::NetHttpExt.new(request_host) }

    setup do
      net_http.stubs(:http_proxy).returns(http_proxy)
      net_http.stubs(:proxy_http_request?).returns(true)
    end

    test 'set @data[:proxy] to proxy' do
      assert net_http.proxy?
      assert_equal URI.parse(http_proxy), net_http.instance_variable_get(:@foreman_proxy_uri)
    end

    test 'rescues requests and mentions proxy' do
      stub_request(:get, "http://#{request_host}/features")
      assert_raises_with_message StandardError.new, "Failed to open TCP connection" do
        net_http.request(Net::HTTP::Get.new("/features"))
      end
    end
  end

  describe 'RestClient::Resource extension' do
    let(:rest_client_request) { RestClient::Request.new(url: request_host, method: 'get') }

    setup do
      RestClient::Request.class_eval { prepend Foreman::HttpProxy::RestClientExtension } if RestClient::Request.ancestors.first != Foreman::HttpProxy::RestClientExtension
      rest_client_request.stubs(:http_proxy).returns(http_proxy)
      rest_client_request.stubs(:proxy_http_request?).returns(true)
    end

    test 'proxy_uri returns proxy' do
      assert_equal URI.parse(http_proxy), rest_client_request.proxy_uri
    end

    test 'sets @proxy for request' do
      net_http_object = rest_client_request.net_http_object(request_host, 8080)
      assert_equal URI.parse(http_proxy).hostname, net_http_object.instance_variable_get(:@proxy_address)
    end
  end
end
