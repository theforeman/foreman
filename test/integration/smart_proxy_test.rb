require 'test_helper'

class SmartProxyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(smart_proxies_path,"Smart Proxies","New Smart Proxy",false)
  end

  test "create new page" do
    assert_new_button(smart_proxies_path,"New Smart Proxy",new_smart_proxy_path)
    fill_in "smart_proxy_name", :with => "DNS Worldwide"
    fill_in "smart_proxy_url", :with => "http://dns.example.com"
    assert_submit_button(smart_proxies_path)
    assert page.has_link? "DNS Worldwide"
    assert page.has_content? "http://dns.example.com"
  end

  test "edit page" do
    visit smart_proxies_path
    click_link "DHCP Proxy"
    click_link "Edit"
    fill_in "smart_proxy_name", :with => "DHCP Secure"
    fill_in "smart_proxy_url", :with => "https://secure.net:8443"
    assert_submit_button(smart_proxy_path(smart_proxies(:one)))
    assert page.has_title? 'DHCP Secure'
    assert page.has_content? "https://secure.net:8443"
  end

  test "show page" do
    proxy = smart_proxies(:one)
    visit smart_proxy_path(proxy)
    assert page.has_selector?('h1', :text => proxy.to_label), "#{proxy.to_label} <h1> tag, but was not found"
    assert page.has_content? proxy.url
    assert page.has_link? "Delete"
    assert page.has_link? "Edit"
    assert page.has_link? "Refresh"
    assert page.has_link? "Services"
    click_link "Services"
    # smart_proxies(:one) has DHCP feature
    assert page.has_selector?('h3', :text => "DHCP")
    assert page.has_content? "Version"
  end
end
