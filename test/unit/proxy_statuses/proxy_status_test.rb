require 'test_helper'

class ProxyStatusTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryGirl.
      build_stubbed(:template_smart_proxy, :url => 'https://secure.proxy:4568')
  end

  test '#versions_cache_key' do
    proxy_status = ProxyStatus::Version.new(@proxy)
    assert_equal("proxy_#{@proxy.id}/Version", proxy_status.cache_key)
  end
end
