require 'test_helper'

class Api::V1::ReportsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end

  test "should show individual record" do
    get :show, { :id => reports(:report).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should destroy report" do
    assert_difference('Report.count', -1) do
      delete :destroy, { :id => reports(:report).to_param }
    end
    assert_response :success
  end

  test "should get reports for given host only" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
    assert_equal 1, reports.count
  end

  test "should return empty result for host with no reports" do
    get :index, {:host_id => hosts(:two).to_param }
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert reports.empty?
    assert_equal 0, reports.count
  end

  test "should get last report" do
    get :last
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
  end

  test "should get last report for given host only" do
    get :last, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
  end

  test "should give error if no last report for given host" do
    get :last, {:host_id => hosts(:two).to_param }
    assert_response 500
  end

end
