require 'test_helper'

class SubnetIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(subnets_path,"Subnets","New Subnet")
  end

  describe 'js tests' do
    setup do
      @driver = Capybara.current_driver
      Capybara.current_driver = Capybara.javascript_driver
      login_admin
    end

    teardown do
      Capybara.current_driver = @driver
    end

    test "create new page" do
      visit new_subnet_path
      assert page.has_link?('Parameters', :href => '#params')
      fill_in "subnet_name", :with => "home-office"
      fill_in "subnet_network", :with => "10.0.0.77"
      fill_in "subnet_mask", :with => "255.255.255.0"
      click_link 'Parameters'
      find('#parameters>a.btn').click

      wait_for_ajax
      find(:css, "[placeholder='Name']").set("subnet_param_key")
      find(:css, "[placeholder='Value']").set("subnet_param_value")
      assert_submit_button(subnets_path)
      assert page.has_link? "home-office"
    end
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
