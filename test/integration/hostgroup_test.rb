require 'test_helper'

class HostgroupTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(hostgroups_path,"Host Groups","New Host Group")
  end

  test "create new page" do
    assert_new_button(hostgroups_path,"New Host Group",new_hostgroup_path)
    fill_in "hostgroup_name", :with => "staging"
    select "production", :from => "hostgroup_environment_id"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'staging'
  end

  test "edit page" do
    visit hostgroups_path
    click_link "Common"
    fill_in "hostgroup_name", :with => "Common Old"
    assert_submit_button(hostgroups_path)
    assert page.has_link? 'Common Old'
  end

end
