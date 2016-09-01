require 'integration_test_helper'

class ComputeResourceIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(compute_resources_path,"Compute Resources","New Compute Resource")
  end

  test "edit compute resource" do
    visit compute_resources_path
    click_link "mycompute"
    click_link "Edit"
    fill_in "compute_resource_name", :with => "mycompute_old"
    assert_submit_button(compute_resources_path)
    assert page.has_link? 'mycompute_old'
  end

  test "compute resource password doesn't deleted while test connection" do
    visit compute_resources_path
    click_link "Vmware"
    click_link "Edit"
    fill_in "compute_resource_password", :disabled => true, :with => "123456"
    click_button "Load Datacenters"
    assert_equal "123456", find_field("compute_resource_password",:disabled => true).value
  end
end
