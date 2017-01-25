require 'integration_test_helper'

class AboutIntegrationTest < IntegrationTestWithJavascript
  setup do
    ComputeResource.any_instance.expects(:ping).at_least_once.returns([])
    proxy_status = mock('ProxyStatus::Version')
    proxy_status.expects(:version).at_least_once.returns('version' => '1.13.0')
    SmartProxy.any_instance.expects(:statuses).at_least_once.returns(:version => proxy_status)
  end

  test "about page" do
    assert_index_page(about_index_path,"About", nil, false, false)
    wait_for_ajax
    assert page.has_selector?('h4', :text => "System Status"), "System Status was expected in the <h4> tag, but was not found"
    assert page.has_selector?('h4', :text => "Support"), "Support was expected in the <h4> tag, but was not found"
    assert page.has_selector?('h4', :text => "System Information"), "System Information was expected in the <h4> tag, but was not found"
    assert page.has_link?("Smart Proxies", :href => "#smart_proxies")
    assert page.has_link?("Compute Resources", :href => "#compute_resources")
    assert page.has_link?("Foreman Users", :href => "http://groups.google.com/group/foreman-users")
    assert page.has_link?("Foreman Developers", :href => "http://groups.google.com/group/foreman-dev")
    assert page.has_link?("issue tracker", :href => "http://projects.theforeman.org/projects/foreman/issues")
    assert page.has_link?("Wiki", :href => "http://projects.theforeman.org")
    assert page.has_link?("Ohad Levy", :href => "mailto:ohadlevy@gmail.com")
    assert page.has_content?("Version")
  end

  test "about page proxies should have version" do
    visit about_index_path
    wait_for_ajax
    assert page.has_selector?('th', :text => "Version")
    assert page.has_selector?('div.proxy-version', :text => '1.13.0')
  end

  private

  def wait_for_ajax
    super
    assert page.has_no_selector?('div.spinner'), 'AJAX spinners still active'
  end
end
