require 'test_helper'

class AuthSourceLdapIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(auth_source_ldaps_path,"LDAP Authentication","New LDAP Source",false,false)
  end

  test "create new page" do
    assert_new_button(auth_source_ldaps_path,"New LDAP Source",new_auth_source_ldap_path)
    fill_in "auth_source_ldap_name", :with => "corporate-ldap"
    fill_in "auth_source_ldap_host", :with => "10.0.0.77"
    fill_in "auth_source_ldap_port", :with => "5555"
    fill_in "auth_source_ldap_account", :with => "superadmin"
    fill_in "auth_source_ldap_account_password", :with => "secretsecret"
    fill_in "auth_source_ldap_base_dn", :with => "dn=x,dn=y"
    fill_in "auth_source_ldap_attr_login", :with => "johndoe"
    fill_in "auth_source_ldap_attr_firstname", :with => "John"
    fill_in "auth_source_ldap_attr_lastname", :with => "Doe"
    fill_in "auth_source_ldap_attr_mail", :with => "john@example.com"
    select 'FreeIPA', :from => "auth_source_ldap_server_type"
    assert_submit_button(auth_source_ldaps_path)
    assert page.has_link? "corporate-ldap"
    assert page.has_content? "10.0.0.77"
  end

  test "edit auth_source_ldaps_path" do
    visit auth_source_ldaps_path
    click_link "ldap-server"
    fill_in "auth_source_ldap_name", :with => "testing-ldap"
    fill_in "auth_source_ldap_host", :with => "10.1.2.34"
    assert_submit_button(auth_source_ldaps_path)
    assert page.has_link? "testing-ldap"
    assert page.has_content? '10.1.2.34'
  end
end
