require 'test_helper'

class ProxyStatusTftpTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.
      build_stubbed(:template_smart_proxy, :url => 'https://secure.proxy:4568')
  end

  test 'it returns tftp server ip' do
    ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
    proxy_status = ProxyStatus::TFTP.new(@proxy)
    assert_equal('127.13.0.1', proxy_status.server)
  end

  test 'it caches tftp_server' do
    ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
    ProxyStatus::TFTP.new(@proxy).server
    assert_equal('127.13.0.1', Rails.cache.fetch("proxy_#{@proxy.id}/TFTP"))
  end

  test 'it does not cache tftp_server if set to false' do
    ProxyAPI::TFTP.any_instance.stubs(:bootServer).returns('127.13.0.1')
    tftp_server = ProxyStatus::TFTP.new(@proxy, {:cache => false}).server
    assert_equal('127.13.0.1', tftp_server)
    assert_nil(Rails.cache.fetch("proxy_#{@proxy.id}/TFTP"))
  end

  test 'it should catch connection setup exceptions' do
    ProxyAPI::Version.any_instance.stubs(:proxy_versions).raises(Errno::ENOENT)
    assert_raise(Foreman::WrappedException, "Unable to connect to smart proxy") do
      ProxyStatus::Version.new(@proxy).versions
    end
  end
end
