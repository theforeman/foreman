require 'test_helper'

class OrganizationIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    FactoryGirl.create(:host)
  end

  test "index page" do
    assert_index_page(organizations_path,"Organizations","New Organization")
  end

  # context - has nil hosts
  test "index page has notice if nil hosts" do
    Host.update_all(:organization_id => nil)
    visit organizations_path
    assert has_selector?("div.alert", :text => "with no organization assigned")
  end

  # context - does not nil hosts
  test "index page does not show notice if all hosts" do
    Host.update_all(:organization_id => Organization.first.id)
    visit locations_path
    assert has_no_selector?("div.alert", :text => "with no organization assigned")
  end

  # context - creating when all hosts are assigned
  test "create new page when all hosts are assigned a organization" do
    Host.update_all(:organization_id => Organization.first.id)
    assert !has_selector?("div.alert", :text => "with no organization assigned")
    assert_new_button(organizations_path,"New Organization",new_organization_path)
    fill_in "organization_name", :with => "Finance"
    assert_submit_button(organizations_path)
    assert page.has_link? "Finance"
  end

  # content - click Assign All
  test "create new page when some hosts are NOT assigned a organization - click Assign All" do
    assert_new_button(organizations_path,"New Organization",new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Assign All"
    assert_current_path organizations_path
    assert page.has_link? "Finance"
  end

  # content - click Manually Assign
  test "create new page when some hosts are NOT assigned a organization - click Manually Assign" do
    assert_new_button(organizations_path,"New Organization",new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Manually Assign"
    assert_current_path assign_hosts_organization_path(Organization.unscoped.order(:id).last)
    assert_submit_button(organizations_path, "Assign to Organization")
    assert page.has_link? "Finance"
  end

  # click Proceed to Edit
  test "create new page when some hosts are NOT assigned a organization - click Proceed to Edit" do
    assert_new_button(organizations_path,"New Organization",new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Proceed to Edit"
    assert_current_path edit_organization_path(Organization.unscoped.order(:id).last)
    assert page.has_selector?('h1', :text => "Edit"), "Edit was expected in the <h1> tag, but was not found"
  end

  test "multiselect does not add items that are filtered out" do
    Capybara.current_driver = Capybara.javascript_driver
    login_admin

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

  # PENDING
  # test "mismatches report" do
  # end
end
