require 'integration_test_helper'

class DashboardIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   DashboardIntegrationTest.test_0005_dashboard link hosts that had pending changes

  def setup
    Dashboard::Manager.reset_user_to_default(users(:admin))
    Setting[:outofsync_interval] = 35
  end

  test 'widgets not in dashboard show up in list' do
    deleted_widget = users(:admin).widgets.last
    users(:admin).widgets.destroy(deleted_widget)
    Capybara.reset_sessions!
    login_admin
    visit dashboard_path
    wait_for_ajax
    assert_equal deleted_widget.name, page.find('li.widget-add a', :visible => :hidden).text(:all)
  end
end
