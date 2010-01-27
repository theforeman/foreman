require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Report model" do
    assert_not_nil ReportsController.active_scaffold_config
    assert ReportsController.active_scaffold_config.model == Report
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should create report" do
    h = Host.create  :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                      :domain => Domain.find_or_create_by_name("company.com"),
                      :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                      :architecture => Architecture.find_or_create_by_name("i386"),
                      :environment => Environment.find_or_create_by_name("envy"),
                      :disk => "empty partition"

    p = Puppet::Transaction::Report.new
    p.logs << Logger.new("willWork")
    p.save

    d = Date.today

    assert_difference('Report.count') do
      post :create, :report => { :commit => "Create", :record => { :host => h, :log => p, :reported_at => d } }
    end

    assert_redirected_to reports_path
  end

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
    h = Host.create  :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                      :domain => Domain.find_or_create_by_name("company.com"),
                      :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                      :architecture => Architecture.find_or_create_by_name("i386"),
                      :environment => Environment.find_or_create_by_name("envy"),
                      :disk => "empty partition"

    p = Puppet::Transaction::Report.new
    p.logs << Logger.new("lalala")
    p.save

    @report = Report.create :host => h, :log => p, :reported_at => Date.new
  end
end

