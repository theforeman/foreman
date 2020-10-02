require 'integration_test_helper'

class OrganizationIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:host, :organization => nil)
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
    assert has_no_selector?("div.alert", :text => "with no organization assigned")
    assert_new_button(organizations_path, "New Organization", new_organization_path)
    fill_in "organization_name", :with => "Finance"
    assert_submit_button(/Finance/i)
    assert page.has_link? 'Primary'
  end

  # content - click Assign All
  test "create new page when some hosts are NOT assigned a organization - click Assign All" do
    assert_new_button(organizations_path, "New Organization", new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Assign All"
    assert_current_path organizations_path
    assert page.has_link? "Finance"
  end

  # content - click Manually Assign
  test "create new page when some hosts are NOT assigned a organization - click Manually Assign" do
    assert_new_button(organizations_path, "New Organization", new_organization_path)
    fill_in "organization_name", :with => "Finance"
    click_button "Submit"
    assert_current_path step2_organization_path(Organization.unscoped.order(:id).last)
    click_link "Manually Assign"
    assert_current_path assign_hosts_organization_path(Organization.unscoped.order(:id).last)
    assert_submit_button(organizations_path, "Assign to Organization")
    assert page.has_link? "Finance"
  end

  # PENDING
  # test "mismatches report" do
  # end
end
