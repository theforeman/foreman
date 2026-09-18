require 'test_helper'

class ConfigReportTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    @report = ConfigReport.import read_json_fixture("reports/skipped.json")
  end

  test "it should true on error? if there were errors" do
    @report.status = {"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3, "pending" => 0}
    assert @report.error?
  end

  test "it should not be an error if there are only skips" do
    @report.status = {"applied" => 92, "restarted" => 300, "failed" => 0, "failed_restarts" => 0, "skipped" => 3, "pending" => 0}
    assert !@report.error?
  end

  test "it should false on error? if there were no errors" do
    @report.status = {"applied" => 92, "restarted" => 300, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    assert !@report.error?
  end

  test 'hooks are defined' do
    expected = [
      'config_report_created.event.foreman',
      'config_report_updated.event.foreman',
      'config_report_destroyed.event.foreman',
    ]
    assert_same_elements expected, ConfigReport.event_subscription_hooks
  end
end
