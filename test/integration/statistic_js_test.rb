require 'integration_test_helper'

class StatisticIntegrationJSTest < IntegrationTestWithJavascript
  test "add statistics" do
    visit statistics_path
    click_link "New Statistic"
    fill_in "statistic_name", :with => "facter-version"
    fail(page.body)
    select2 "operatingsystem", :from => "statistic_value"
    assert_submit_button(statistics_path)
    assert page.has_selector?('h4', :text => 'facter-version')
  end
end
