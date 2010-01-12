require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    @r=Report.import File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/report-skipped.yaml"))
  end

  test "it should not change host report status when we have skipped reports but there are no log entries" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 1}
    assert_equal @r.failed, 0
  end

  test "it should save metrics as bits in status integer" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3}
    @r.save
    assert_equal @r.applied, Report::MAX
    assert_equal @r.restarted, Report::MAX
    assert_equal @r.failed, 4
    assert_equal @r.failed_restarts, 12
    assert_equal @r.skipped, 3
  end

  test "it should true on error? if there were errors" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3}
    assert @r.error?
  end

  test "it should false on error? if there were no errors" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 0, "failed_restarts" => 0, "skipped" => 0}
    assert @r.error? == false
  end

  test "with named scope should return our report with applied resources" do
    @r.status={"applied" => 15, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 0}
    @r.save
    assert Report.with("applied",14).include?(@r)
    assert Report.with("applied",15).include?(@r) == false
  end

  test "with named scope should return our report with restarted resources" do
    @r.status={"applied" => 0, "restarted" => 5, "failed" => 0, "failed_restarts" => 0, "skipped" => 0}
    @r.save
    assert Report.with("restarted").include?(@r)
  end

  test "with named scope should return our report with failed resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 0, "skipped" => 0}
    @r.save
    assert Report.with("failed").include?(@r)
  end

  test "with named scope should return our report with failed_restarts resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 91, "skipped" => 0}
    @r.save
    assert Report.with("failed_restarts").include?(@r)
  end

  test "with named scope should return our report with skipped resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 8}
    @r.save
    assert Report.with("skipped").include?(@r)
  end

  test "with named scope should return our report with skipped resources when other bits are also used" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 4, "skipped" => 8}
    @r.save
    assert Report.with("skipped").include?(@r)
  end
end
