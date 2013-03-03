require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  test "get hosts" do
    visit "/hosts"
    page.has_selector?('h1', :text => 'Hosts')
    assert find_link('New Host').visible?
    assert find_button('Search').visible?
    assert has_content? "Name"
    assert has_content? "Operating System"
    assert has_content? "Environment"
    assert has_content? "Model"
    assert has_content? "Host Group"
    assert has_content? "Last report"
  end

  test "create host" do
    visit "/hosts"
    click_link "New Host"
    assert_equal current_path, new_host_path
    fill_in "host_name", :with => "foreman.test.com"
    select "Common", :from => "host_hostgroup_id"
    select "production", :from => "host_environment_id"

    click_button "Submit"
    assert_equal current_path, hosts_path
    assert page.has_content? 'foreman.test.com'
  end

end
