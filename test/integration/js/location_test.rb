require 'test_helper'

class LocationTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  # context - location is valid
  test "edit page" do
    visit locations_path
    within(:xpath, "//tr[contains(.,'Location 1')]") do
      first("a").click
    end
    fill_in "location_name", :with => "TLV"
    # make location valid by click all checkmarks
    within(:xpath, "//form") do
      click_link("Users")
      check("location_ignore_types_user")
      click_link("Smart Proxies")
      check("location_ignore_types_smartproxy")
      click_link("Subnets")
      check("location_ignore_types_subnet")
      click_link("Compute Resources")
      check("location_ignore_types_computeresource")
      click_link("Media")
      check("location_ignore_types_medium")
      click_link("Templates")
      check("location_ignore_types_configtemplate")
      click_link("Domains")
      check("location_ignore_types_domain")
      click_link("Environments")
      check("location_ignore_types_environment")
      click_link("Host Groups")
      check("location_ignore_types_hostgroup")
      click_link("Organizations")
      first("div#ms-location_organization_ids ul li").click
    end
    assert_submit_button(locations_path)
    assert page.has_link? 'TLV'
  end

  test "sucessfully delete row" do
     assert_delete_row(locations_path, "Location 2", "Delete", true)
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(locations_path, "Location 1", "Delete", true)
  end

  # PENDING
  # test "clone row" do
  # end

end
