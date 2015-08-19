require 'test_helper'

class CommonParameterIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(common_parameters_path,"Global Parameters","New Parameter")
  end

  test "create new page" do
    assert_new_button(common_parameters_path,"New Parameter",new_common_parameter_path)
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
end
