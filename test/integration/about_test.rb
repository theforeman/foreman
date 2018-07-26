require 'integration_test_helper'

class AboutIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   AboutIntegrationTest.test_0002_about page proxies should have version

  setup do
    ComputeResource.any_instance.expects(:ping).at_least_once.returns([])
    proxy_status = mock('ProxyStatus::Version')
    proxy_status.expects(:version).at_least_once.returns('version' => '1.13.0')
    SmartProxy.any_instance.expects(:statuses).at_least_once.returns(:version => proxy_status)
  end

  test "about page" do
    assert_index_page(about_index_path, "About", nil, false, false)
    wait_for_ajax
    assert_selector 'h4', text: 'System Status'
    assert_selector 'h4', text: 'Support'
    assert_selector 'h4', text: 'System Information'
    assert_link 'Smart Proxies', href: '#smart_proxies'
    assert_link 'Compute Resources', href: '#compute_resources'
    assert_link 'community forums', href: 'https://community.theforeman.org'
    assert_link 'issue tracker', href: 'http://projects.theforeman.org/projects/foreman/issues'
    assert_link 'Wiki', href: 'http://projects.theforeman.org'
    assert_link 'Ohad Levy', href: 'mailto:ohadlevy@gmail.com'
    assert_content 'Version'
  end

  test "about page proxies should have version" do
    visit about_index_path
    wait_for_ajax
    assert_selector 'th', text: 'Version'
    assert_selector 'div.proxy-version', text: '1.13.0'
  end

  private

  def wait_for_ajax
    super
    assert page.has_no_selector?('div.spinner'), 'AJAX spinners still active'
  end
end
