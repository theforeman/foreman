require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest

  def assert_dashboard_link(text)
    visit dashboard_path
    assert page.has_link?(text), "link '#{text}' was expected, but it does not exist"
    click_link(text)
    assert_equal systems_path, current_path, "new path #{systems_path} was expected but it was #{current_path}"
    assert_not_nil find_field('search').value
  end

  test "dashboard page" do
    assert_index_page(dashboard_path,"Overview",false,true,false)
    assert page.has_content? 'Generated at'
  end

  test "dashboard link systems that had performed modifications" do
    assert_dashboard_link 'Systems that had performed modifications without error'
  end

  test "dashboard link systems in error state" do
    assert_dashboard_link 'Systems in error state'
  end

  test "dashboard link good system reports" do
    assert_dashboard_link 'Good system reports in the last 35 minutes'
  end

  test "dashboard link systems that had pending changes" do
    assert_dashboard_link 'Systems that had pending changes'
  end

  test "dashboard link out of sync systems" do
    assert_dashboard_link 'Out of sync Systems'
  end

  test "dashboard link systems with no reports" do
    assert_dashboard_link 'Systems with no reports'
  end

  test "dashboard link systems with alerts disabled" do
    assert_dashboard_link 'Systems with alerts disabled'
  end

end
