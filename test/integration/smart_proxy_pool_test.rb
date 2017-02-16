require 'integration_test_helper'

class SmartProxyPoolIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(smart_proxy_pools_path, "Smart Proxy Pools", "Create Smart Proxy Pool")
  end

  test "create new page" do
    assert_new_button(smart_proxy_pools_path, "Create Smart Proxy Pool", new_smart_proxy_pool_path)
    fill_in "smart_proxy_pool_name", :with => "my new pool"
    fill_in "smart_proxy_pool_hostname", :with => "my-new-hostname.com"
    assert_submit_button(smart_proxy_pools_path)
    assert page.has_link? 'my new pool'
  end

  test "edit page" do
    visit smart_proxy_pools_path
    assert page.has_content? smart_proxies(:puppetmaster).name
    click_link smart_proxy_pools(:puppetmaster).name
    fill_in "smart_proxy_pool_name", :with => "Updated Puppet Smart Proxy Pool"
    assert_submit_button(smart_proxy_pools_path)
    assert page.has_link? "Updated Puppet Smart Proxy Pool"
  end
end
