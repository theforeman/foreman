require 'test_helper'

class AuthSourceLdapTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(auth_source_ldaps_path, "ldap-server")
  end

end
