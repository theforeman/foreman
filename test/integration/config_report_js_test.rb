require 'integration_test_helper'

class ConfigReportJSTest < IntegrationTestWithJavascript
  let(:report) { FactoryBot.create(:report, :old_report) }

  test "show specific report" do
    visit config_report_path(report)
    assert_breadcrumb_text(report.host.fqdn)
  end

  test "should display report metrics chart" do
    report = ConfigReport.import(read_json_fixture('reports/applied.json'))
    visit config_report_path(report)
    assert page.find('.donut-chart-pf')
  end

  test "index page" do
    report
    visit config_reports_path
    assert find_button('Search').visible?, "Search button is not visible"
  end

  test "reports for host" do
    report
    visit config_reports_path
    click_link(report.host.name)
    has_selector?(".rbt-input-main", text: "host = #{report.host.name}", wait: 3)
    assert_equal "host = #{report.host.name}", find('.rbt-input-main').value
  end
end
