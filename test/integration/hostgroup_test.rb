require 'test_helper'

class HostgroupTest < ActionDispatch::IntegrationTest
 test "get hostgroups" do
    visit "/"
    click_link "Host Groups"
    page.has_selector?('h1', :text => 'Host Groups')
    assert find_link('New Hostgroup').visible?
    assert find_button('Search').visible?
    page.has_selector?("table")
    assert has_content? "Name"
  end

  test "create new hostgroup" do
    visit "/"
    click_link "Host Groups"
    click_link "New Hostgroup"
    assert_equal current_path, new_hostgroup_path
    fill_in "hostgroup_name", :with => "newhostgroup"
    select "production", :from => "hostgroup_environment_id"
    click_button "Submit"
    assert_equal current_path, hostgroups_path
    assert page.has_content? 'newhostgroup'
  end

  test "edit hostgroup" do
    visit "/"
    click_link "Host Groups"
    click_link "Common"
    fill_in "hostgroup_name", :with => "Common Old"
    click_button "Submit"
    assert_equal current_path, hostgroups_path
    assert page.has_content? 'Common Old'
  end

  # PENDING
  # test "nest Hostgroup" do
  # end

  # PENDING
  # test "delete Hostgroup" do
  # end
end
