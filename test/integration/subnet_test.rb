require 'test_helper'

class SubnetIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(subnets_path,"Subnets","New Subnet")
  end

  test "create new page" do
    assert_new_button(subnets_path,"New Subnet",new_subnet_path)
    fill_in "subnet_name", :with => "home-office"
    fill_in "subnet_network", :with => "10.0.0.77"
    fill_in "subnet_mask", :with => "255.255.255.0"
    assert_submit_button(subnets_path)
    assert page.has_link? "home-office"
  end

  test "edit page" do
    visit subnets_path
    click_link "one"
    fill_in "subnet_name", :with => "one-secure"
    fill_in "subnet_network", :with => "10.1.1.177"
    assert_submit_button(subnets_path)
    assert page.has_link? 'one-secure'
  end
end
