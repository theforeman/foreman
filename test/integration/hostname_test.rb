require 'integration_test_helper'

class HostnameIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(hostnames_path,"Smart Proxy Hostnames","Create Hostname")
  end

  test "create new page" do
    assert_new_button(hostnames_path,"Create Hostname",new_hostname_path)
    fill_in "hostname_name", :with => "my-new-hostname.com"
    fill_in "hostname_hostname", :with => "my-new-hostname.com"
    assert_submit_button(hostnames_path)
    assert page.has_link? 'my-new-hostname.com'
  end

  test "edit page" do
    visit hostnames_path
    assert page.has_content? smart_proxies(:puppetmaster).name
    click_link hostnames(:puppetmaster).name
    fill_in "hostname_name", :with => "Updated Puppet Hostname"
    assert_submit_button(hostnames_path)
    assert page.has_link? "Updated Puppet Hostname"
  end
end
