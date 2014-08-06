require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    @r=Report.import read_json_fixture("report-skipped.json")
  end

  test "it should true on error? if there were errors" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3, "pending" => 0}
    assert @r.error?
  end

  test "it should not be an error if there are only skips" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 0, "failed_restarts" => 0, "skipped" => 3, "pending" => 0}
    assert !@r.error?
  end

  test "it should false on error? if there were no errors" do
    @r.status={"applied" => 92, "restarted" => 300, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    assert !@r.error?
  end

  test "with named scope should return our report with applied resources" do
    @r.status={"applied" => 15, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @r.save
    assert Report.with("applied",14).include?(@r)
    assert !Report.with("applied", 15).include?(@r)
  end

  test "with named scope should return our report with restarted resources" do
    @r.status={"applied" => 0, "restarted" => 5, "failed" => 0, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @r.save
    assert Report.with("restarted").include?(@r)
  end

  test "with named scope should return our report with failed resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 0, "skipped" => 0, "pending" => 0}
    @r.save
    assert Report.with("failed").include?(@r)
  end

  test "with named scope should return our report with failed_restarts resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 91, "skipped" => 0, "pending" => 0}
    @r.save
    assert Report.with("failed_restarts").include?(@r)
  end

  test "with named scope should return our report with skipped resources" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 8, "pending" => 0}
    @r.save
    assert Report.with("skipped").include?(@r)
  end

  test "with named scope should return our report with skipped resources when other bits are also used" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 4, "skipped" => 8, "pending" => 3}
    @r.save
    assert Report.with("skipped").include?(@r)
  end

  test "with named scope should return our report with pending resources when other bits are also used" do
    @r.status={"applied" => 0, "restarted" => 0, "failed" => 9, "failed_restarts" => 4, "skipped" => 8, "pending" => 3}
    @r.save
    assert Report.with("pending").include?(@r)
  end

  test "should expire reports created 1 week ago" do
    report_count = 25
    Message.delete_all
    Source.delete_all
    FactoryGirl.create_list(:report, report_count, :with_logs)
    FactoryGirl.create_list(:report, report_count, :with_logs, :old_report)
    assert Report.count > report_count*2
    assert_difference('Report.count', -1*report_count) do
      assert_difference(['Log.count', 'Message.count', 'Source.count'], -1*report_count*30) do
        Report.expire
      end
    end
  end

end
