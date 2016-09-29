require 'test_helper'
require 'controllers/shared/report_host_permissions_test'

class Api::V1::ReportsControllerTest < ActionController::TestCase
  include ::ReportHostPermissionsTest

  setup do
    Foreman::Deprecation.expects(:api_deprecation_warning).with('Reports were renamed to ConfigReports')
  end

  test "should get index" do
    FactoryGirl.create(:report)
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end

  test "should show individual record" do
    report = FactoryGirl.create(:report)
    get :show, { :id => report.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should destroy report" do
    report = FactoryGirl.create(:report)
    assert_difference('Report.count', -1) do
      delete :destroy, { :id => report.to_param }
    end
    assert_response :success
    refute Report.find_by_id(report.id)
  end

  test "should get reports for given host only" do
    report = FactoryGirl.create(:report)
    get :index, {:host_id => report.host.to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
    assert_equal 1, reports.count
  end

  test "should return empty result for host with no reports" do
    host = FactoryGirl.create(:host)
    get :index, {:host_id => host.to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert reports.empty?
    assert_equal 0, reports.count
  end

  test "should get last report" do
    reports = FactoryGirl.create_list(:config_report, 5)
    get :last
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
    assert_equal reports.last, Report.find(report['report']['id'])
  end

  test "should get last report for given host only" do
    main_report = FactoryGirl.create(:config_report)
    FactoryGirl.create_list(:report, 5)
    get :last, {:host_id => main_report.host.to_param }
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
    assert_equal main_report, Report.find(report['report']['id'])
  end

  test "should give error if no last report for given host" do
    host = FactoryGirl.create(:host)
    get :last, {:host_id => host.to_param }
    assert_response :not_found
  end

  test 'cannot view the last report without hosts view permission' do
    setup_user('view', 'config_reports')
    report = FactoryGirl.create(:report)
    get :last, { :host_id => report.host.id }, set_session_user.merge(:user => User.current.id)
    assert_response :not_found
  end
end
