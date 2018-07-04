require 'integration_test_helper'

class LocationJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(locations_path, "Locations", "New Location")
  end
end
