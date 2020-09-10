require 'integration_test_helper'

class CommonParameterIntegrationTest < ActionDispatch::IntegrationTest
  test "create new page" do
    assert_new_button(common_parameters_path, "Create Parameter", new_common_parameter_path)
    fill_in "common_parameter_name", :with => "ssh_debug_key"
    fill_in "common_parameter_value", :with => "ssh-rsa AAAAB3NzaC1yc2E"
    assert_submit_button(common_parameters_path)
    assert page.has_link? 'ssh_debug_key'
    assert page.has_content? 'ssh-rsa AAAAB3NzaC1yc2E'
  end

  test "edit page" do
    visit common_parameters_path
    click_link "test"
    fill_in "common_parameter_value", :with => "mynewvalue"
    assert_submit_button(common_parameters_path)
    assert page.has_content? 'mynewvalue'
  end

  test "does not display editor on hidden value" do
    visit common_parameters_path
    click_link "test"
    check "common_parameter_hidden_value"
    page.assert_no_selector 'editor_source'
  end
end
