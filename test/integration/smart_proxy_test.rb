require 'integration_test_helper'

class SmartProxyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(smart_proxies_path,"Smart Proxies","New Smart Proxy",false)
    visit smart_proxies_path
    if SETTINGS[:locations_enabled]
      assert page.has_selector?('th', :text => 'Locations')
    else
      refute page.has_selector?('th', :text => 'Locations')
    end
  end

  test "create new page" do
    assert_new_button(smart_proxies_path,"New Smart Proxy",new_smart_proxy_path)
    fill_in "smart_proxy_name", :with => "DNS Worldwide"
    fill_in "smart_proxy_url", :with => "http://dns.example.com"
    assert_submit_button(smart_proxies_path)
    assert page.has_link? "DNS Worldwide"
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

  describe 'pagelets on show page' do
    setup do
      @view_paths = SmartProxiesController.view_paths
      SmartProxiesController.prepend_view_path File.expand_path('../../static_fixtures/views', __FILE__)
    end

    def teardown
      Pagelets::Manager.clear
      SmartProxiesController.view_paths = @view_paths
    end

    test 'show page passes subject into pagelets' do
      Pagelets::Manager.add_pagelet("smart_proxies/show", :main_tabs,
                                                          :name => "VisibleTab",
                                                          :partial => "/test",
                                                          :onlyif => Proc.new { |subject| subject.has_feature? "DHCP" })
      Pagelets::Manager.add_pagelet("smart_proxies/show", :main_tabs,
                                                          :name => "HiddenTab",
                                                          :partial => "/test",
                                                          :onlyif => Proc.new { |subject| subject.has_feature? "TFTP" })
      proxy = smart_proxies(:one)
      visit smart_proxy_path(proxy)
      assert page.has_link?("VisibleTab")
      refute page.has_link?("HiddenTab")
    end
  end
end
