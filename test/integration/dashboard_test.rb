require 'integration_test_helper'

class DashboardIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   DashboardIntegrationTest.test_0005_dashboard link hosts that had pending changes

  def setup
    Dashboard::Manager.reset_user_to_default(users(:admin))
    Setting[:outofsync_interval] = 35
  end

  def assert_dashboard_link(text)
    visit_dashboard
    assert page.has_link?(text), "link '#{text}' was expected, but it does not exist"
    within "li[data-name='Host Configuration Status for All']" do
      click_link(text)
    end
    assert_current_path hosts_path, :ignore_query => true
    assert_match(/search=/, current_url)
  end

  def visit_dashboard
    visit dashboard_path
    wait_for_ajax
  end

  test "dashboard page" do
    assert_index_page(dashboard_path, "Overview", false, true, false)
    wait_for_ajax
    assert page.has_content? 'Generated at'
  end

  test "dashboard link hosts that had performed modifications" do
    assert_dashboard_link 'Hosts that had performed modifications without error'
  end

  test "dashboard link hosts in error state" do
    assert_dashboard_link 'Hosts in error state'
  end

  test "dashboard link good host reports" do
    assert_dashboard_link "Good hosts with reports"
  end

  test "dashboard link hosts that had pending changes" do
    assert_dashboard_link 'Hosts that had pending changes'
  end

  test "dashboard link out of sync hosts" do
    assert_dashboard_link 'Out of sync hosts'
  end

  context 'with origin' do
    setup do
      Setting::Puppet.load_defaults
      Setting[:puppet_out_of_sync_disabled] = true
    end

    context 'out of sync disabled' do
      test 'has no out of sync link' do
        visit_dashboard
        within "li[data-name='Host Configuration Status for Puppet']" do
          assert page.has_no_link?('Out of sync hosts')
          assert page.has_link?('Good hosts with reports')
        end
      end
    end
  end

  test "dashboard link hosts with no reports" do
    assert_dashboard_link 'Hosts with no reports'
  end

  test "dashboard link hosts with alerts disabled" do
    assert_dashboard_link 'Hosts with alerts disabled'
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
