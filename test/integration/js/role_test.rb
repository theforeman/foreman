require 'test_helper'

class RoleTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(roles_path, "Manager")
  end

  test "check and uncheck all roles" do
    visit roles_path
    click_link "Manager"
    click_link "uncheck_all_roles"
    assert has_unchecked_field?("role_permissions_"), "Expected checkbox NOT to be checked, but it was"
    click_link "check_all_roles"
    assert has_checked_field?("role_permissions_"), "Expected checkbox to be checked, but it was NOT"
  end

end
