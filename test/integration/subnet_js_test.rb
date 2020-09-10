require 'integration_test_helper'

class SubnetJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   SubnetJSIntegrationTest.test_0001_create new page
  test "index page" do
    assert_index_page(subnets_path, "Subnets", "Create Subnet")
  end

  test "create new page" do
    visit new_subnet_path
    assert page.has_link?('Parameters', :href => '#params')
    fill_in "subnet_name", :with => "home-office"
    fill_in "subnet_network", :with => "10.0.0.77"
    fill_in "subnet_cidr", :with => "24"
    click_link 'Parameters'
    find('#parameters>a.btn').click

    wait_for_ajax
    find(:css, "[placeholder='Name']").set("subnet_param_key")
    find(:css, "[placeholder='Value']").set("subnet_param_value")
    assert_submit_button(subnets_path)
    assert page.has_link? "home-office"
  end
end
