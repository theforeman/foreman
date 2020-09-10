require 'integration_test_helper'

class OrganizationJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(organizations_path, "Organizations", "New Organization")
  end
  test "multiselect does not add items that are filtered out" do
    visit edit_organization_path(taxonomies(:organization1))

    wait_for_ajax
    within "#content" do
      click_link "Locations"
      within "#locations" do
        find(".ms-selection").assert_no_selector("li[selected='selected']")
        find(".ms-selectable").find("input").set("Location 1")
        find("a[data-original-title='Select All']").click
        find(".ms-selection").find(".ms-selected").find("span").has_text? "Location 1"
      end
    end
  end
end
