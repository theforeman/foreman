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

  test "with named scope should return our report with applied resources" do
    @report.status = {"applied" => 15, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @report.save
    assert ConfigReport.with("applied", 14).include?(@report)
    assert !ConfigReport.with("applied", 15).include?(@report)
  end

  test "with named scope should return our report with restarted resources" do
    @report.status = {"applied" => 0, "restarted" => 5, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @report.save
    assert ConfigReport.with("restarted").include?(@report)
  end

  test "with named scope should return our report with failed resources" do
    @report.status = {"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @report.save
    assert ConfigReport.with("failed").include?(@report)
  end

  test "with named scope should return our report with failed_restarts resources" do
    @report.status = {"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 91, "skipped" => 0, "pending" => 0}
    @report.save
    assert ConfigReport.with("failed_restarts").include?(@report)
  end

  test "with named scope should return our report with skipped resources" do
    @report.status = {"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 8, "pending" => 0}
    @report.save
    assert ConfigReport.with("skipped").include?(@report)
  end

  test "with named scope should return our report with skipped resources when other bits are also used" do
    @report.status = {"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 4, "skipped" => 8, "pending" => 3}
    @report.save
    assert ConfigReport.with("skipped").include?(@report)
  end

  test "with named scope should return our report with pending resources when other bits are also used" do
    @report.status = {"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 4, "skipped" => 8, "pending" => 3}
    @report.save
    assert ConfigReport.with("pending").include?(@report)
  end
end
