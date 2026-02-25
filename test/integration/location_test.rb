require 'integration_test_helper'

class LocationIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:host, :location => nil)
  end

  # context - has nil hosts
  test "index page has notice if nil hosts" do
    Host.update_all(:location_id => nil)
    visit locations_path
    assert has_selector?("div.alert", :text => "with no location assigned")
  end

  # context - does not nil hosts
  test "index page does not show notice if all hosts" do
    Host.update_all(:location_id => Location.first.id)
    visit locations_path
    assert has_no_selector?("div.alert", :text => "with no location assigned")
  end

  # context - creating when all hosts are assigned
  test "create new page when all hosts are assigned a location" do
    Host.update_all(:location_id => Location.first.id)
    assert has_no_selector?("div.alert", :text => "with no location assigned")
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "Raleigh"
    assert_submit_button(/Raleigh/i)
    assert page.has_link? 'Primary'
  end

  # content - click Assign All
  test "create new page when some hosts are not assigned a location and click Assign All" do
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_current_path step2_location_path(Location.unscoped.order(:id).last)
    click_link "Assign All"
    assert_current_path locations_path
    assert page.has_link? "Raleigh"
  end

  # content - click Manually Assign
  test "create new page when some hosts are not assigned a location and click Manually Assign" do
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_current_path step2_location_path(Location.unscoped.order(:id).last)
    click_link "Manually Assign"
    assert_current_path assign_hosts_location_path(Location.unscoped.order(:id).last)
    assert_submit_button(locations_path, "Assign to Location")
    assert page.has_link? "Raleigh"
  end

  test "create a location with an unprivileged user with admin usergroup" do
    ug = FactoryBot.create(:usergroup, :admin => true)
    user = FactoryBot.create(:user, :usergroups => [ug])

    set_request_user(user)
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "Raleigh"
    click_button "Submit"
    assert_current_path step2_location_path(Location.unscoped.order(:id).last)
  end

  test "create a location with an unprivileged user with create_locations permission" do
    user = setup_user('view', 'locations')
    setup_user('create', 'locations', 'name ~ "R*"')
    set_request_user(user)
    assert_new_button(locations_path, "New Location", new_location_path)
    fill_in "location_name", :with => "aleigh2"
    click_button "Submit"
    error = find('div.alert')
    assert_match "You don't have permission create_locations", error.text

    fill_in "location_name", :with => "Raleigh2"
    click_button "Submit"
    assert_current_path edit_location_path(Location.unscoped.order(:id).last)
  end

  # PENDING
  # test "mismatches report" do
  # end
end
