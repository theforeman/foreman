require 'test_helper'

class UsergroupTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(usergroups_path,"User Groups","New User Group",false)
  end

  test "create new page" do
    assert_new_button(usergroups_path,"New User Group",new_usergroup_path)
    fill_in "usergroup_name", :with => "bosses"
    assert_submit_button(usergroups_path)
    assert page.has_link? "bosses"
  end

  test "edit page" do
    visit usergroups_path
    click_link "Admins"
    fill_in "usergroup_name", :with => "SuperAdmins"
    assert_submit_button(usergroups_path)
    assert page.has_link? 'SuperAdmins'
  end

end
