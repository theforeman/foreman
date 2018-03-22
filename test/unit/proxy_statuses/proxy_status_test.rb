require 'test_helper'

class ProxyStatusTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.
      build_stubbed(:template_smart_proxy, :url => 'https://secure.proxy:4568')
  end

  test '#api returns new ProxyAPI object' do
    ProxyStatus::Version.expects(:humanized_name).returns('Version')
    api = mock('ProxyAPI::Version')
    ProxyAPI::Version.expects(:new).with(:url => @proxy.url).returns(api)
    assert_equal api, ProxyStatus::Version.new(@proxy).send(:api)
  end

  test '#api raises exceptions for unknown ProxyAPI classes' do
    ProxyStatus::Base.expects(:humanized_name).at_least_once.returns('Unknown')
    ex = assert_raise(Foreman::WrappedException) { ProxyStatus::Base.new(@proxy).send(:api) }
    assert_match /ProxyAPI class ProxyAPI::Unknown/, ex.message
  end

  test '#cache_key' do
    proxy_status = ProxyStatus::Version.new(@proxy)
    assert_equal("proxy_#{@proxy.id}/Version", proxy_status.cache_key)
  end
end
