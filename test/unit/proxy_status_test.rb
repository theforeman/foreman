require 'test_helper'

class ProxyStatusTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryGirl.
      build_stubbed(:template_smart_proxy, :url => 'https://secure.proxy:4568')
  end

  test '#versions_cache_key' do
    proxy_status = ProxyStatus.new(@proxy)
    assert_equal("proxy_#{@proxy.id}/versions", proxy_status.versions_cache_key)
  end

  context '#tftp_server' do
    test 'it returns tftp server ip' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
      proxy_status = ProxyStatus.new(@proxy)
      assert_equal('127.13.0.1', proxy_status.tftp_server)
    end

    test 'it caches tftp_server' do
      ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
      ProxyStatus.new(@proxy).tftp_server
      assert_equal('127.13.0.1', Rails.cache.fetch("proxy_#{@proxy.id}/tftp_server"))
    end

    test 'it raises an error if proxy has no tftp feature' do
      proxy = FactoryGirl.build_stubbed(:smart_proxy)
      assert_raise Foreman::Exception do
        ProxyStatus.new(proxy).tftp_server
      end
    end
  end

  context '#api_versions' do
    setup do
      @expected_versions = {'version' => '1.11', 'modules' => {'dns' => '1.11'}}
      ProxyAPI::Version.any_instance.stubs(:proxy_versions).returns(@expected_versions)
    end

    test 'it returns version from the proxy' do
      proxy_status = ProxyStatus.new(@proxy)
      assert_equal(@expected_versions, proxy_status.api_versions)
    end

    test 'it caches api_versions' do
      ProxyStatus.new(@proxy).api_versions
      assert_equal(@expected_versions, Rails.cache.fetch("proxy_#{@proxy.id}/versions"))
    end

    test 'it raises error if no connection to proxy' do
      ProxyAPI::Version.any_instance.stubs(:proxy_versions).raises(Net::HTTPBadResponse)
      assert_raise(Foreman::WrappedException, "Unable to connect to smart proxy") do
        ProxyStatus.new(@proxy).api_versions
      end
    end
  end
end
