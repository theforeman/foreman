require 'integration_test_helper'

class ComputeProfileIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  test "create new page" do
    assert_new_button(compute_profiles_path, "Create Compute Profile", new_compute_profile_path)
    fill_in "compute_profile_name", :with => "5-XXLarge"
    click_button 'Submit'
    assert page.has_selector?('h1', :text => '5-XXLarge'), "5-XXLarge was expected in the <h1> tag, but was not found"
  end

  test "edit page" do
    visit edit_compute_profile_path(compute_profiles(:one))
    fill_in "compute_profile_name", :with => "1-Tiny"
    assert_submit_button(compute_profiles_path)
    assert page.has_link? '1-Tiny'
  end

  test "show page" do
    visit compute_profiles_path
    click_link("1-Small")
    assert page.has_selector?('h1', :text => '1-Small'), "1-Small was expected in the <h1> tag, but was not found"
  end
end
