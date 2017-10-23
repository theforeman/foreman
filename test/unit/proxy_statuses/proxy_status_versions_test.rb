require 'test_helper'

class ProxyStatusVersionsTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.
      build_stubbed(:template_smart_proxy, :url => 'https://secure.proxy:4568')
    @expected_versions = {'version' => '1.11', 'modules' => {'dns' => '1.11'}}
    ProxyAPI::Version.any_instance.stubs(:proxy_versions).returns(@expected_versions)
  end

  test 'it returns version from the proxy' do
    proxy_status = ProxyStatus::Version.new(@proxy)
    assert_equal(@expected_versions, proxy_status.versions)
  end

  test 'it caches versions' do
    ProxyStatus::Version.new(@proxy).versions
    assert_equal(@expected_versions, Rails.cache.fetch("proxy_#{@proxy.id}/Version"))
  end

  test 'it does not cache versions when set not to' do
    versions = ProxyStatus::Version.new(@proxy, {:cache => false}).versions
    assert_equal(@expected_versions, versions)
    assert_nil(Rails.cache.fetch("proxy_#{@proxy.id}/Version"))
  end

  test 'it raises error if no connection to proxy' do
    ProxyAPI::Version.any_instance.stubs(:proxy_versions).raises(Net::HTTPBadResponse)
    assert_raise(Foreman::WrappedException, "Unable to connect to smart proxy") do
      ProxyStatus::Version.new(@proxy).versions
    end
  end
end
