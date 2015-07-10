require 'test_helper'

class DashboardIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    FactoryGirl.create(:host)
    Dashboard::Manager.reset_user_to_default(users(:admin))
  end

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

  test "dashboard link hosts that had performed modifications" do
    assert_dashboard_link 'Hosts that had performed modifications without error'
  end

  test "dashboard link hosts in error state" do
    assert_dashboard_link 'Hosts in error state'
  end

  test "dashboard link good host reports" do
    assert_dashboard_link 'Good host reports in the last 35 minutes'
  end

  test "dashboard link hosts that had pending changes" do
    assert_dashboard_link 'Hosts that had pending changes'
  end

  test "dashboard link out of sync hosts" do
    assert_dashboard_link 'Out of sync hosts'
  end

  test "dashboard link hosts with no reports" do
    assert_dashboard_link 'Hosts with no reports'
  end

  test "dashboard link hosts with alerts disabled" do
    assert_dashboard_link 'Hosts with alerts disabled'
  end
end
