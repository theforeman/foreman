require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('reports')
    assert_template 'index'
  end

  def test_show
    create_a_puppet_transaction_report
    Report.last.update_attribute :log, @log
    get :show, {:id => Report.last.id}, set_session_user
    assert_template 'show'
  end

  def test_create_invalid
    create_a_puppet_transaction_report
    @log.host = nil
    post :create, {:report => @log.to_yaml}, set_session_user
    assert_response :error
  end

  def test_create_valid
    create_a_puppet_transaction_report
    post :create, {:report => @log.to_yaml}, set_session_user
    assert_response :success
  end

  def test_destroy
    report = Report.first
    delete :destroy, {:id => report}, set_session_user
    assert_redirected_to reports_url
    assert !Report.exists?(report.id)
  end

  test "should show report" do
    create_a_report
    assert @report.save!

    get :show, {:id => @report.id}, set_session_user
    assert_response :success
  end

  test "should destroy report" do
    create_a_report
    assert @report.save!

    assert_difference('Report.count', -1) do
      delete :destroy, {:id => @report.id}, set_session_user
    end

    assert_redirected_to reports_path
  end

  def create_a_report
    create_a_puppet_transaction_report

    @report = Report.create :host => hosts(:one), :log => @log, :reported_at => Time.new
  end

  def create_a_puppet_transaction_report
    @log = Puppet::Transaction::Report.new
    @log.time = Time.now.utc
    @log.metrics["time"] = Puppet::Util::Metric.new(:info)
    @log.metrics["time"].values = [[:user, "User", 0.0135350227355957], [:total, "Total", 16.5941832065582], [:service, "Service", 1.46307373046875], [:package, "Package", 0.608669757843018], [:file, "File", 5.92631697654724], [:ssh_authorized_key, "Ssh authorize
d key", 0.00355410575866699], [:group, "Group", 0.00506687164306641], [:schedule, "Schedule", 0.00130486488342285], [:cron, "Cron", 0.0011448860168457], [:config_retrieval, "Config retrieval", 7.56520414352417], [:exec, "Exec", 1.00578165054321], [:filebucket, "F
ilebucket", 0.000531196594238281]]
    @log.metrics["resources"] = Puppet::Util::Metric.new(:info)
    @log.metrics["resources"].values = [[:total, "Total", 1273], [:applied, "Applied", 1], [:restarted, "Restarted", 0], [:skipped, "Skipped", 0], [:out_of_sync, "Out of sync", 1], [:scheduled, "Scheduled", 786], [:failed_restarts, "Failed restarts", 0], [:failed, "Failed", 0]]
    l = Puppet::Util::Log.new(:level => "notice", :message => :foo, :tags => %w{foo bar})
    @log.logs << l
    @log.save
  end
end
