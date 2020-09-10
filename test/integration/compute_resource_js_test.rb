require 'integration_test_helper'

class ComputeResourceJSIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   ComputeResourceJSIntegrationTest.test_0002_add new compute attributes two pane

  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  test "compute resource password isn't deleted when testing connection" do
    visit compute_resources_path
    click_link "Vmware"
    click_link "Edit"
    find("#disable-pass-btn").click
    fill_in "compute_resource_password", :with => "123456"
    click_link "Test Connection"
    assert_equal "123456", find_field("compute_resource_password").value
    wait_for_ajax
  end

  test "index page" do
    assert_index_page(compute_resources_path, "Compute Resources", "Create Compute Resource")
  end
end
