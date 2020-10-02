require 'integration_test_helper'

class LocationJSTest < IntegrationTestWithJavascript
  let(:unlocalized_host) { FactoryBot.create(:host, location: nil) }

  test "index page" do
    assert_index_page(locations_path, "Locations", "New Location")
  end

  # click Proceed to Edit
  test "create new page when some hosts are and assigned a location and click Proceed to Edit" do
    unlocalized_host
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_current_path step2_location_path(Location.unscoped.order(:id).last)
    click_link "Proceed to Edit"
    assert_current_path edit_location_path(Location.unscoped.order(:id).last)
    assert_breadcrumb_text('Edit')
  end
end
