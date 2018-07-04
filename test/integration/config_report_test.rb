require 'integration_test_helper'

class ConfigReportIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @report = FactoryBot.create(:report, :old_report)
  end

  test "show specific report" do
    visit config_report_path(@report)
    assert page.has_selector?('h1', :text => @report.host.fqdn), "hostname was expected in the <h1> tag, but was not found"
  end

  test "delete a report redirects to reports index" do
    visit config_report_path(@report)
    first(:link, "Delete").click
    assert_current_path config_reports_path
  end

  test "adrift report displays warning" do
    report = FactoryBot.create(:report, :adrift)
    visit config_report_path(report)
    assert has_content?('Host times seem to be adrift!')
  end
end
