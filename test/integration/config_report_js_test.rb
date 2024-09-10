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
    assert_index_page(config_reports_path, "Reports", nil, true)
  end

  test "reports for host" do
    report
    visit config_reports_path
    click_link(report.host.name)
    has_selector?(".foreman-search-bar .pf-v5-c-text-input-group__text-input", text: "host = #{report.host.name}", wait: 3)
    assert_equal "host = #{report.host.name}", find('.foreman-search-bar .pf-v5-c-text-input-group__text-input').value
  end
end
