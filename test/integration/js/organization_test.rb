require 'test_helper'

class OrganizationTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  # context - organization is valid
  test "edit page" do
    visit organizations_path
    within(:xpath, "//tr[contains(.,'Organization 1')]") do
      first("a").click
    end
    fill_in "organization_name", :with => "Human Resources"
    # make organization valid by click all checkmarks
    within(:xpath, "//form") do
      click_link("Users")
      check("organization_ignore_types_user")
      click_link("Smart Proxies")
      check("organization_ignore_types_smartproxy")
      click_link("Subnets")
      check("organization_ignore_types_subnet")
      click_link("Compute Resources")
      check("organization_ignore_types_computeresource")
      click_link("Media")
      check("organization_ignore_types_medium")
      click_link("Templates")
      check("organization_ignore_types_configtemplate")
      click_link("Domains")
      check("organization_ignore_types_domain")
      click_link("Environments")
      check("organization_ignore_types_environment")
      click_link("Host Groups")
      check("organization_ignore_types_hostgroup")
      click_link("Locations")
      first("div#ms-organization_location_ids ul li").click
    end
    assert_submit_button(organizations_path)
    assert page.has_link? 'Human Resources'
  end

  test "sucessfully delete row" do
     assert_delete_row(organizations_path, "Organization 2", "Delete", true)
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(organizations_path, "Organization 1", "Delete", true)
  end

  # PENDING
  # test "clone row" do
  # end

end
