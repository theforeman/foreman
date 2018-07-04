require 'integration_test_helper'

class RoleIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(roles_path, "Create Role", new_role_path)
    fill_in "role_name", :with => "Big Boss"
    assert_submit_button(roles_path)
    assert page.has_link? "Big Boss"
  end

  test "edit page" do
    visit roles_path
    click_link "Destroy hosts"
    fill_in "role_name", :with => "Vice President"
    assert_submit_button(roles_path)
    assert page.has_link? 'Vice President'
  end

  # PENDING
  # permission report
end
