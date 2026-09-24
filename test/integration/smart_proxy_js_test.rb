require 'integration_test_helper'
require 'pagelets_test_helper'

class SmartProxyJSTest < IntegrationTestWithJavascript
  setup do
    stub_smart_proxy_v2_features_and_statuses
  end

  test "index page" do
    assert_index_page(smart_proxies_path, "Smart Proxies", "Create Smart Proxy", false)
    assert page.has_selector?('th', :text => 'Locations')
  end

  test "create new page" do
    assert_new_button(smart_proxies_path, "Create Smart Proxy", new_smart_proxy_path)
    fill_in "smart_proxy_name", :with => "DNS Worldwide"
    fill_in "smart_proxy_url", :with => "http://dns.example.com"
    assert_submit_button(smart_proxies_path)
    assert page.has_link? "DNS Worldwide"
  end

  test "edit page" do
    visit smart_proxies_path
    wait_for_ajax
    click_link "DHCP Proxy"
    click_link "Edit"
    fill_in "smart_proxy_name", :with => "DHCP Secure"
    fill_in "smart_proxy_url", :with => "https://secure.net:8443"
    assert_submit_button(smart_proxy_path(smart_proxies(:one)))
    assert page.has_title? 'DHCP Secure'
    assert_equal 'https://secure.net:8443', smart_proxies(:one).reload.url
  end

  test "show page" do
    proxy = smart_proxies(:one)
    visit smart_proxy_path(proxy)
    assert_breadcrumb_text(proxy.to_label)
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

  test "dismisses popovers when switching tabs" do
    proxy = smart_proxies(:one)
    visit smart_proxy_path(proxy)
    click_link "Services"
    assert page.has_selector?('h3', :text => "DHCP")

    page.execute_script(<<~JS)
      var trigger = document.createElement('a');
      trigger.setAttribute('rel', 'popover');
      trigger.setAttribute('href', '#');
      trigger.setAttribute('data-content', 'Spool error help');
      trigger.setAttribute('data-container', 'body');
      trigger.setAttribute('data-trigger', 'focus');
      trigger.textContent = 'info';
      document.getElementById('services').appendChild(trigger);
      $(trigger).popover('show');
    JS

    assert page.has_selector?('.popover', visible: true)
    within('#proxy-tab') { click_link 'Overview' }
    assert page.has_no_selector?('.popover', visible: true)
  end

  describe 'pagelets on show page' do
    include PageletsIsolation

    setup do
      @view_paths = SmartProxiesController.view_paths
      SmartProxiesController.prepend_view_path File.expand_path('../static_fixtures/views', __dir__)
    end

    def teardown
      SmartProxiesController.view_paths = @view_paths
    end

    test 'show page passes subject into pagelets' do
      Pagelets::Manager.add_pagelet("smart_proxies/show", :main_tabs,
        :name => "VisibleTab",
        :partial => "/test",
        :onlyif => proc { |subject| subject.has_feature? "DHCP" })
      Pagelets::Manager.add_pagelet("smart_proxies/show", :main_tabs,
        :name => "HiddenTab",
        :partial => "/test",
        :onlyif => proc { |subject| subject.has_feature? "TFTP" })
      proxy = smart_proxies(:one)
      visit smart_proxy_path(proxy)
      assert page.has_link?("VisibleTab")
      assert page.has_no_link?("HiddenTab")
    end
  end
end
