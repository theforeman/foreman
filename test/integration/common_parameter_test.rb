require 'test_helper'

class CommonParameterTest < ActionDispatch::IntegrationTest
  test "get global parameters" do
    visit "/"
    click_link "Global Parameters"
    assert find_link('New Parameter').visible?
    page.has_selector?('h1', :text => 'Global Parameters')
    page.has_selector?("table")
    assert has_content? "Name"
    assert has_content? "Value"
  end

  test "create new global parameter" do
    visit "/"
    click_link "Global Parameters"
    click_link "New Parameter"
    assert_equal current_path, new_common_parameter_path
    fill_in "common_parameter_name", :with => "ssh_debug_key"
    fill_in "common_parameter_value", :with => "ssh-rsa AAAAB3NzaC1yc2E"
    click_button "Submit"
    assert_equal current_path, common_parameters_path
    assert page.has_content? 'ssh_debug_key'
  end

  test "edit global parameter" do
    visit "/"
    click_link "Global Parameters"
    click_link "test"
    fill_in "common_parameter_value", :with => "mynewvalue"
    click_button "Submit"
    assert_equal current_path, common_parameters_path
    assert page.has_content? 'mynewvalue'
  end

  # PENDING
  # test "delete global parameter" do
  # end

end
