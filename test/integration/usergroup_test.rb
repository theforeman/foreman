require 'integration_test_helper'

class UsergroupIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    as_admin { @usergroup = FactoryBot.create(:usergroup) }
  end

  test "index page" do
    assert_index_page(usergroups_path,"User Groups","Create User Group",false)
  end

  test "create new page" do
    assert_new_button(usergroups_path,"Create User Group",new_usergroup_path)
    fill_in "usergroup_name", :with => "bosses"
    assert_submit_button(usergroups_path)
    assert page.has_link? "bosses"
  end

  test "edit page" do
    visit usergroups_path
    click_link @usergroup.name
    fill_in "usergroup_name", :with => "SuperAdmins"
    assert_submit_button(usergroups_path)
    assert page.has_link? 'SuperAdmins'
  end
end
