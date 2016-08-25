require 'integration_test_helper'

class ComputeResourceJSIntegrationTest < IntegrationTestWithJavascript
  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  def check_two_pane(compute_resource, compute_profile)
    profile_name = compute_profile.name

    visit compute_resource_path(compute_resource)

    # Select Compute profiles tab and open two pane for the compute profile
    click_link("Compute profiles")
    click_link(profile_name)

    assert page.has_selector?('div.two-pane-right'), "Right pane didn't open"

    # Hit Submit and check the original table is displayed again
    click_button('Submit')
    assert has_link?(profile_name), "Compute profile table wasn't displayed again"

    # Check the pane is closed
    assert page.has_no_selector?('div.two-pane-right'), "Right pane didn't close"
  end

  test "edit compute attributes two pane" do
    check_two_pane(compute_resources(:ec2), compute_profiles(:one))
  end

  test "add new compute attributes two pane" do
    check_two_pane(compute_resources(:ec2), compute_profiles(:three))
  end
end
