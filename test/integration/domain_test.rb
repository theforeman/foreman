require 'integration_test_helper'

class DomainIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(domains_path, "Create Domain", new_domain_path)
    fill_in "domain_name", :with => "ynet.tlv.com"
    assert_submit_button(domains_path)
    assert page.has_link? 'ynet.tlv.com'
  end

  test "edit page" do
    visit domains_path
    click_link "mydomain.net"
    fill_in "domain_name", :with => "my.updated.domain.org"
    assert_submit_button(domains_path)
    assert page.has_link? 'my.updated.domain.org'
  end
end
