require 'integration_test_helper'

class ConfigReportJSTest < IntegrationTestWithJavascript
  test "should display report metrics chart" do
    report = ConfigReport.import(read_json_fixture('reports/applied.json'))
    visit config_report_path(report)
    assert page.find('.donut-chart-pf')
  end
end
