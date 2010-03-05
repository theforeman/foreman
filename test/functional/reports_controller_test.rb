require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def setup
    @host = Host.create   :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                          :domain => Domain.find_or_create_by_name("company.com"),
                          :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                          :architecture => Architecture.find_or_create_by_name("i386"),
                          :environment => Environment.find_or_create_by_name("envy"),
                          :disk => "empty partition"
  end

  test "ActiveScaffold should look for Report model" do
    assert_not_nil ReportsController.active_scaffold_config
    assert ReportsController.active_scaffold_config.model == Report
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  # couldn't test create, cause uses Report.import which needs yaml, but create passes it hash

  # test "should create report" do
  #   create_a_puppet_transaction_report

    # assert_difference('Report.count') do
    #   post :create, :report => { :commit => "Create", :record => { :host => h, :log => p, :reported_at => d } }
    # end

  #   assert_redirected_to reports_path
  # end

  test "should show report" do
    create_a_report
    assert @report.save!

    get :show, :id => @report.id
    assert_response :success
  end

  test "should destroy report" do
    create_a_report
    assert @report.save!

    assert_difference('Report.count', -1) do
      delete :destroy, :id => @report.id
    end

    assert_redirected_to reports_path
  end

  def create_a_report
    create_a_puppet_transaction_report

    @report = Report.create :host => @host, :log => @log, :reported_at => Time.new
  end

  def create_a_puppet_transaction_report
    @log = Puppet::Transaction::Report.new
    @log.metrics["time"] = Puppet::Util::Metric.new(:info)
    @log.metrics["time"].values = [[:user, "User", 0.0135350227355957], [:total, "Total", 16.5941832065582], [:service, "Service", 1.46307373046875], [:package, "Package", 0.608669757843018], [:file, "File", 5.92631697654724], [:ssh_authorized_key, "Ssh authorized key", 0.00355410575866699], [:group, "Group", 0.00506687164306641], [:schedule, "Schedule", 0.00130486488342285], [:cron, "Cron", 0.0011448860168457], [:config_retrieval, "Config retrieval", 7.56520414352417], [:exec, "Exec", 1.00578165054321], [:filebucket, "Filebucket", 0.000531196594238281]]
    l = Puppet::Util::Log.new(:level => "notice", :message => :foo, :tags => %w{foo bar})
    @log.logs << l
    @log.save
  end
end

