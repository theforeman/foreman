require 'integration_test_helper'

class CommonParameterIntegrationTest < IntegrationTestWithJavascript
  test "create new page" do
    assert_new_button(common_parameters_path, "Create Parameter", new_common_parameter_path)
    fill_in "common_parameter_name", :with => "ssh_debug_key"
    find('#editor').click
    find('.ace_content').send_keys "ssh-rsa AAAAB3NzaC1yc2E"
    sleep 1 # Wait for the editor onChange debounce
    assert_submit_button(common_parameters_path)
    assert page.has_link? 'ssh_debug_key'
    assert page.has_content? 'ssh-rsa AAAAB3NzaC1yc2E'
  end

  test "edit page" do
    visit common_parameters_path
    click_link "test"
    find('#editor').click
    find('.ace_content').send_keys "new"
    sleep 1 # Wait for the editor onChange debounce
    assert_submit_button(common_parameters_path)
    assert page.has_content? 'myvaluenew'
  end
end
