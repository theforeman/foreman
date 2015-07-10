require 'test_helper'

class ComputeProfileIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  test "index page" do
    assert_index_page(compute_profiles_path,"Compute profiles","New Compute Profile")
  end

  test "create new page" do
    assert_new_button(compute_profiles_path,"New Compute Profile",new_compute_profile_path)
    fill_in "compute_profile_name", :with => "5-XXLarge"
    click_button 'Submit'
    assert page.has_selector?('h1', :text => 'Compute profile: 5-XXLarge'), "Compute profile: 5-XXLarge was expected in the <h1> tag, but was not found"
  end

  test "edit page" do
    # 'Edit' link is js two-pane, so visit edit path directly
    visit edit_compute_profile_path(compute_profiles(:one))
    fill_in "compute_profile_name", :with => "1-Tiny"
    assert_submit_button(compute_profiles_path)
    assert page.has_link? '1-Tiny'
  end

  test "show page" do
    visit compute_profiles_path
    click_link("1-Small")
    assert page.has_selector?('h1', :text => 'Compute profile: 1-Small'), "Compute profile: 1-Small was expected in the <h1> tag, but was not found"
  end

  test "edit compute attribute page" do
    visit compute_profile_path(compute_profiles(:one))
    # amazon123 exists in fixture compute_attributes.yml
    click_link("amazon123 (eu-west-1-EC2)")
    assert page.has_selector?('h1', :text => 'Edit compute profile on amazon123 (eu-west-1-EC2)'), "Edit compute profile on amazon123 (eu-west-1-EC2) was expected in the <h1> tag, but was not found"
  end

  test "new compute attribute page" do
    visit compute_profile_path(compute_profiles(:one))
    # another-ec2 is not in fixture compute_attributes.yml
    click_link("another-ec2 (eu-west-1-EC2)")
    assert page.has_selector?('h1', :text => 'New compute profile on another-ec2 (eu-west-1-EC2)'), "New compute profile on another-ec2 (eu-west-1-EC2) was expected in the <h1> tag, but was not found"
  end
end
