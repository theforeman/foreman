require 'integration_test_helper'

class ComputeProfileJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   ComputeProfileJSTest.test_0001_edit compute attribute page
  extend MiniTest::OptionalRetry

  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  test "edit compute attribute page" do
    visit compute_profile_path(compute_profiles(:one))
    # amazon123 exists in fixture compute_attributes.yml
    click_link("amazon123 (eu-west-1-EC2)")

    selected_profile = find("#s2id_compute_attribute_compute_profile_id .select2-chosen").text
    assert_equal compute_profiles(:one).name, selected_profile

    selected_compute = find("#s2id_compute_attribute_compute_resource_id .select2-chosen").text
    assert_equal "amazon123 (eu-west-1-EC2)", selected_compute

    click_button('Submit')
    assert has_link?("amazon123 (eu-west-1-EC2)")
    # two pane should close on save
    assert page.has_no_selector?('div.two-pane-right')
  end
end
