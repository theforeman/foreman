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
    report_count = 3
    Message.delete_all
    Source.delete_all
    FactoryGirl.create_list(:report, report_count, :with_logs)
    FactoryGirl.create_list(:report, report_count, :with_logs, :old_report)
    assert Report.count > report_count*2
    assert_difference('Report.count', -1*report_count) do
      assert_difference(['Log.count', 'Message.count', 'Source.count'], -1*report_count*5) do
        Report.expire
      end
    end
  end

  describe '.my_reports' do
    setup do
      @target_host = FactoryGirl.create(:host, :with_hostgroup)
      @target_reports = FactoryGirl.create_pair(:report, host: @target_host)
      @other_host = FactoryGirl.create(:host, :with_hostgroup)
      @other_reports = FactoryGirl.create_pair(:report, host: @other_host)
    end

    test 'returns all reports for admin' do
      as_admin do
        assert_empty (@target_reports + @other_reports).map(&:id) - Report.my_reports.map(&:id)
      end
    end

    test 'returns visible reports for unlimited user' do
      user_role = FactoryGirl.create(:user_user_role)
      FactoryGirl.create(:filter, :role => user_role.role, :permissions => Permission.where(:name => 'view_hosts'), :unlimited => true)
      collection = as_user(user_role.owner) { Report.my_reports }
      assert_empty (@target_reports + @other_reports).map(&:id) - collection.map(&:id)
    end

    test 'returns visible reports for filtered user' do
      user_role = FactoryGirl.create(:user_user_role)
      FactoryGirl.create(:filter, :role => user_role.role, :permissions => Permission.where(:name => 'view_hosts'), :search => "hostgroup_id = #{@target_host.hostgroup_id}")
      as_user user_role.owner do
        assert_equal @target_reports.map(&:id).sort, Report.my_reports.map(&:id).sort
      end
    end
  end
end
