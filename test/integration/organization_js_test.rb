require 'integration_test_helper'

class OrganizationJSTest < IntegrationTestWithJavascript
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

  test "test per page in hosts assign" do
    FactoryBot.create_list(:host, 10, organization: nil)
    org = FactoryBot.create(:organization)
    visit assign_hosts_organization_path(org)
    # to validate that the pagination doesn't look odd look for ".content-view-pf-pagination"
    assert page.has_css?(".content-view-pf-pagination")
    assert page.has_content?("1-10")
    assert page.has_css?('#per_page')
    page.find("select > option[value='5']").select_option
    assert page.has_content?("1-5")
  end
end
