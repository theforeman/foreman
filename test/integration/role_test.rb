require 'test_helper'

class RoleTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(roles_path,"Roles","New Role")
  end

  test "create new page" do
    assert_new_button(roles_path,"New Role",new_role_path)
    fill_in "role_name", :with => "Big Boss"
    assert_submit_button(roles_path)
    assert page.has_link? "Big Boss"
  end

  test "edit page" do
    visit roles_path
    click_link "Manager"
    fill_in "role_name", :with => "Vice President"
    assert_submit_button(roles_path)
    assert page.has_link? 'Vice President'
  end

  # PENDING
  # permission report
end
