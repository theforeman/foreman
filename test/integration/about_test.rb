require 'test_helper'

class AboutIntegrationTest < ActionDispatch::IntegrationTest
  test "about page" do
    visit about_index_path
    assert_index_page(about_index_path,"About", nil, false, false)
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
end
