require 'integration_test_helper'

class ComputeProfileJSTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   ComputeProfileJSTest.test_0001_edit compute attribute page

  setup do
    Fog.mock!
  end

  teardown do
    Fog.unmock!
  end

  test "create new ComputeProfile" do
    assert_new_button(compute_profiles_path, "Create Compute Profile", new_compute_profile_path)
    fill_in "compute_profile_name", :with => "5-XXLarge"
    click_button 'Submit'
    assert_breadcrumb_text('5-XXLarge')
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
    assert_breadcrumb_text('1-Small')
  end

  test "edit compute attribute page" do
    visit compute_profile_path(compute_profiles(:one))
    # amazon123 exists in fixture compute_attributes.yml
    click_link("amazon123 (eu-west-1-EC2)")

    assert page.has_selector?('#breadcrumb .active', :text => compute_profiles(:one).name), "#{compute_profiles(:one).name} was expected in the breadcrumb active, but was not found"
    selected_profile = find("#s2id_compute_attribute_compute_profile_id .select2-chosen").text
    assert_equal compute_profiles(:one).name, selected_profile

    selected_compute = find("#s2id_compute_attribute_compute_resource_id .select2-chosen").text
    assert_equal "amazon123 (eu-west-1-EC2)", selected_compute

    click_button('Submit')
    assert_current_path compute_profile_path(compute_profiles(:one))
  end

  test "create compute profile" do
    visit compute_profiles_path()
    click_on("Create Compute Profile")
    fill_in('compute_profile_name', :with => 'test')
    click_on("Submit")
    assert click_link(compute_resources(:ovirt).to_s)
    selected_profile = find("#s2id_compute_attribute_compute_profile_id .select2-chosen").text
    assert select2('hwp_small', :from => 'compute_attribute_vm_attrs_template')
    wait_for_ajax
    assert click_button("Submit")
    visit compute_profile_path(selected_profile)
    assert click_link(compute_resources(:ovirt).to_s)
    assert_equal  "512 MB", find_field('compute_attribute_vm_attrs_memory').value
    assert_equal  "1", find_field('compute_attribute[vm_attrs][cores]').value
  end

  test "index page" do
    assert_index_page(compute_profiles_path, "Compute Profiles", "Create Compute Profile")
  end
end
