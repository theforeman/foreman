require 'integration_test_helper'

class ComputeResourceIntegrationTest < ActionDispatch::IntegrationTest
  test "edit compute resource" do
    visit compute_resources_path
    click_link "mycompute"
    click_link "Edit"
    fill_in "compute_resource_name", :with => "mycompute_old"
    assert_submit_button(compute_resources_path)
    assert page.has_link? 'mycompute_old'
  end
end
