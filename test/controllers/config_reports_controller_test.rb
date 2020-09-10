require 'test_helper'
require 'controllers/shared/report_host_permissions_test'

class ConfigReportsControllerTest < ActionController::TestCase
  include ::ReportHostPermissionsTest

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  let :report do
    as_admin { FactoryBot.create(:config_report) }
  end

  def test_index
    report
    get :index, session: set_session_user
    assert_response :success
    assert_not_nil assigns('config_reports')
    assert_template 'index'
  end

  test 'csv export works' do
    report
    get :index, params: {format: :csv}, session: set_session_user
    assert_response :success
    assert_equal 2, response.body.lines.size
  end

  test 'csv export respects taxonomy scope' do
    host = FactoryBot.create(:host)
    FactoryBot.create(:config_report, :host => host)

    # "any context"
    get :index, params: {format: :csv}, session: set_session_user
    assert_response :success
    assert_equal 2, response.body.lines.size

    get :index, params: {format: :csv}, session: set_session_user.merge(location_id: host.location_id)
    assert_response :success
    assert_equal 2, response.body.lines.size

    get :index, params: {format: :csv}, session: set_session_user.merge(location_id: FactoryBot.create(:location).id)
    assert_response :success
    assert_equal 1, response.body.lines.size
  end

  def test_show
    get :show, params: { :id => report.id }, session: set_session_user
    assert_template 'show'
  end

  test '404 on show when id is blank' do
    get :show, params: { :id => ' ' }, session: set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last
    report
    get :show, params: { :id => "last" }, session: set_session_user
    assert_template 'show'
  end

  test '404 on last when no reports available' do
    get :show, params: { :id => 'last', :host_id => FactoryBot.create(:host) }, session: set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last_report_for_host
    get :show, params: { :id => "last", :host_id => report.host.to_param }, session: set_session_user
    assert_template 'show'
  end

  def test_render_404_when_invalid_report_for_a_host_is_requested
    get :show, params: { :id => "last", :host_id => "blalala.domain.com" }, session: set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_destroy
    delete :destroy, params: { :id => report }, session: set_session_user
    assert_redirected_to config_reports_url
    assert !ConfigReport.exists?(report.id)
  end

  test "should show report" do
    create_a_report
    assert @report.save!

    get :show, params: { :id => @report.id }, session: set_session_user
    assert_response :success
  end

  test "should destroy report" do
    create_a_report
    assert @report.save!

    assert_difference('ConfigReport.count', -1) do
      delete :destroy, params: { :id => @report.id }, session: set_session_user
    end

    assert_redirected_to config_reports_path
  end

  test 'cannot view the last report without hosts view permission' do
    setup_user('view', 'config_reports')
    get :show, params: { :id => 'last', :host_id => report.host.id }, session: set_session_user.merge(:user => User.current.id)
    assert_response :not_found
  end

  private

  def create_a_report
    @report = ConfigReport.import(read_json_fixture('reports/empty.json'))
  end
end
