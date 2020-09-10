require 'integration_test_helper'

class RealmIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(realms_path, "Create Realm", new_realm_path)
    fill_in "realm_name", :with => "EXAMPLE.COM"
    select "FreeIPA", :from => "realm_realm_type"
    select "Realm Proxy", :from => "realm_realm_proxy_id"
    assert_submit_button(realms_path)
    assert page.has_link? 'EXAMPLE.COM'
  end

  test "edit page" do
    visit realms_path
    click_link "myrealm.net"
    fill_in "realm_name", :with => "my.updated.realm.org"
    assert_submit_button(realms_path)
    assert page.has_link? 'my.updated.realm.org'
  end
end
