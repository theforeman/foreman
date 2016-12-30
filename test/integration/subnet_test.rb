require 'integration_test_helper'

class SubnetIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(subnets_path,"Subnets","Create Subnet")
  end

  test "edit page" do
    visit subnets_path
    click_link "one"
    assert page.has_link?('Parameters', :href => '#params')
    fill_in "subnet_name", :with => "one-secure"
    fill_in "subnet_network", :with => "10.1.1.177"
    assert_submit_button(subnets_path)
    assert page.has_link? 'one-secure'
  end
end
