require 'integration_test_helper'

class OrganizationJSTest < IntegrationTestWithJavascript
  let(:unorganized_host) { FactoryBot.create(:host, organization: nil) }

  test "index page" do
    assert_index_page(organizations_path, "Organizations", "New Organization")
  end

  # click Proceed to Edit
  test "create new page when some hosts are NOT assigned a organization - click Proceed to Edit" do
    unorganized_host
    assert_new_button(organizations_path, "New Organization", new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Proceed to Edit"
    assert_current_path edit_organization_path(Organization.unscoped.order(:id).last)
    assert_breadcrumb_text('Edit')
  end

  test "multiselect does not add items that are filtered out" do
    visit edit_organization_path(taxonomies(:organization1))

    wait_for_ajax
    within "#content" do
      click_link "Locations"
      within "#locations" do
        find(".ms-selection").assert_no_selector("li[selected='selected']")
        find(".ms-selectable").find("input").set("Location 1")
        find("a[title='Select All']").hover
        find("a[data-original-title='Select All']").click
        find(".ms-selection").find(".ms-selected").find("span").has_text? "Location 1"
      end
    end
  end
end
