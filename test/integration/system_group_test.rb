require 'test_helper'

class SystemGroupTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(system_groups_path,"System Groups","New System Group")
  end

  test "create new page" do
    assert_new_button(system_groups_path,"New System Group",new_system_group_path)
    fill_in "system_group_name", :with => "staging"
    select "production", :from => "system_group_environment_id"
    assert_submit_button(system_groups_path)
    assert page.has_link? 'staging'
  end

  test "edit page" do
    visit system_groups_path
    click_link "db"
    fill_in "system_group_name", :with => "db Old"
    assert_submit_button(system_groups_path)
    assert page.has_link? 'db Old'
  end

end
