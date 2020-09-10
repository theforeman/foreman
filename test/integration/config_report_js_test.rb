require 'integration_test_helper'

class ConfigReportJSTest < IntegrationTestWithJavascript
  def setup
    @report = FactoryBot.create(:report, :old_report)
  end
  test "should display report metrics chart" do
    report = ConfigReport.import(read_json_fixture('reports/applied.json'))
    visit config_report_path(report)
    assert page.find('.donut-chart-pf')
  end

  test "index page" do
    visit config_reports_path
    assert find_button('Search').visible?, "Search button is not visible"
  end

  test "reports for host" do
    visit config_reports_path
    click_link(@report.host.name)
    has_selector?(".rbt-input-main", text: "host = #{@report.host.name}", wait: 3)
    assert_equal "host = #{@report.host.name}", find('.rbt-input-main').value
  end
end
