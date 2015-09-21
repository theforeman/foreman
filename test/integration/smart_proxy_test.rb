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
    skip
    visit smart_proxies_path
    click_link "DHCP Proxy"
    new_name = "DHCP Secure #{rand(10000)}"
    fill_in "smart_proxy_name", :with => new_name
    fill_in "smart_proxy_url", :with => "https://secure.net:8443"
    click_button "Submit"
    assert_submit_button(smart_proxies_path)
    assert page.has_link? new_name
    assert page.has_content? "https://secure.net:8443"
  end
end
