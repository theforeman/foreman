require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    User.current = User.admin
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

  def setup_user operation, type = 'reports'
    super
    as_admin do
      @r.save!
    end
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record = @r
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  @r
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should not be able to edit" do
    # Reports are not an editable resource
    setup_user "edit"
    record        =  @r
    record.status = {}
    assert !record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record        =  @r
    record.status = {}
    assert !record.save
    assert record.valid?
  end

end
