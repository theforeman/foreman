require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest

  def assert_dashboard_link(text)
    visit dashboard_path
    assert page.has_link?(text), "link '#{text}' was expected, but it does not exist"
    click_link(text)
    assert_equal hosts_path, current_path, "new path #{hosts_path} was expected but it was #{current_path}"
    assert_not_nil find_field('search').value
  end

  test "dashboard page" do
    assert_index_page(dashboard_path,"Overview",false,true,false)
    assert page.has_content? 'Generated at'
  end

  test "dashboard link Hosts that had performed modifications" do
    assert_dashboard_link 'Hosts that had performed modifications without error'
  end

  test "dashboard link Hosts in Error State" do
    assert_dashboard_link 'Hosts in Error State'
  end

  test "dashboard link Good Host Reports" do
    assert_dashboard_link 'Good Host Reports in the last 35 minutes'
  end

  test "dashboard link Hosts that had pending changes" do
    assert_dashboard_link 'Hosts that had pending changes'
  end

  test "dashboard link Out Of Sync Hosts" do
    assert_dashboard_link 'Out Of Sync Hosts'
  end

  test "dashboard link Hosts With No Reports" do
    assert_dashboard_link 'Hosts With No Reports'
  end

  test "dashboard link Hosts With Alerts Disabled" do
    assert_dashboard_link 'Hosts With Alerts Disabled'
  end

end
