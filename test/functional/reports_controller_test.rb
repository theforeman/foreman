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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report" do
    debugger
    h = Host.create  :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                      :domain => Domain.find_or_create_by_name("company.com"),
                      :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                      :architecture => Architecture.find_or_create_by_name("i386"),
                      :environment => Environment.find_or_create_by_name("envy"),
                      :disk => "empty partition"

    p = Puppet::Transaction::Report.new
    p.logs = "willWork"
    p.save

    d = Date.today

    assert_difference('Report.count') do
      post :create, :report => { :host => h, :log => p, :reported_at => d }
    end

    assert_redirected_to reports_path
  end

  test "should show report" do
    create_a_report
    assert @report.save!

    get :show, :id => @report.id
    assert_response :success
  end

  test "should get edit" do
    create_a_report
    assert @report.save!

    get :edit, :id => @report.id
    assert_response :success
  end

  test "should update report" do
    create_a_report
    assert @report.save!

    q = Puppet::Transaction::Report.new
    q.logs = "lolo"
    q.save

    put :update, { :commit => "Update", :id => @report.id, :record => {:log => q} }
    report = Report.find_by_id(@report.id)
    assert report.log == q

    assert_redirected_to reports_path
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
    p.logs = "willWork"
    p.save

    @report = Report.create :host => h, :log => p, :reported_at => Date.new
  end
end

