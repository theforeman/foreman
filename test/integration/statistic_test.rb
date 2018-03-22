require 'integration_test_helper'

class StatisticIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   StatisticIntegrationTest.test_0001_statistics page

  test "statistics page" do
    visit statistics_path
    wait_for_ajax
    assert page.has_selector?('h3', :text => "OS Distribution")
    assert page.has_selector?('h3', :text => "Architecture Distribution")
    assert page.has_selector?('h3', :text => "Environment Distribution")
    assert page.has_selector?('h3', :text => "Number of CPUs")
    assert page.has_selector?('h3', :text => "Hardware")
    assert page.has_selector?('h3', :text => "Class Distribution")
    assert page.has_selector?('h3', :text => "Average Memory Usage")
    assert page.has_selector?('h3', :text => "Average Swap Usage")
  end
end
