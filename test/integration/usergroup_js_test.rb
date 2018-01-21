require 'integration_test_helper'

class UsergroupJSTest < IntegrationTestWithJavascript
  def setup
    as_admin { @usergroup = FactoryBot.create(:usergroup) }
  end

  test "create new page" do
    visit usergroups_path
    first(:link, "Create User Group").click
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
