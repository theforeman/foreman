require 'test_helper'
require 'controllers/shared/report_host_permissions_test'

class ConfigReportsControllerTest < ActionController::TestCase
  include ::ReportHostPermissionsTest

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  let :report do
    as_admin { FactoryGirl.create(:config_report) }
  end

  def test_index
    report
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('config_reports')
    assert_template 'index'
  end

  test 'csv export works' do
    report
    get :index, {format: :csv}, set_session_user
    assert_response :success
    assert_equal 2, response.body.lines.size
  end

  test 'csv export respects taxonomy scope' do
    host = FactoryGirl.create(:host)
    FactoryGirl.create(:config_report, :host => host)

    # "any context"
    get :index, {format: :csv}, set_session_user
    assert_response :success
    assert_equal 2, response.body.lines.size

    get :index, {format: :csv}, set_session_user.merge(location_id: host.location_id)
    assert_response :success
    assert_equal 2, response.body.lines.size

    get :index, {format: :csv}, set_session_user.merge(location_id: FactoryGirl.create(:location).id)
    assert_response :success
    assert_equal 1, response.body.lines.size
  end

  def test_show
    get :show, {:id => report.id}, set_session_user
    assert_template 'show'
  end

  test '404 on show when id is blank' do
    get :show, {:id => ' '}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last
    report
    get :show, {:id => "last"}, set_session_user
    assert_template 'show'
  end

  test '404 on last when no reports available' do
    get :show, { :id => 'last', :host_id => FactoryGirl.create(:host) }, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last_report_for_host
    get :show, {:id => "last", :host_id => report.host.to_param}, set_session_user
    assert_template 'show'
  end

  def test_render_404_when_invalid_report_for_a_host_is_requested
    get :show, {:id => "last", :host_id => "blalala.domain.com"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_destroy
    delete :destroy, {:id => report}, set_session_user
    assert_redirected_to config_reports_url
    assert !ConfigReport.exists?(report.id)
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

    assert_difference('ConfigReport.count', -1) do
      delete :destroy, {:id => @report.id}, set_session_user
    end

    assert_redirected_to config_reports_path
  end

  test 'cannot view the last report without hosts view permission' do
    setup_user('view', 'config_reports')
    get :show, { :id => 'last', :host_id => report.host.id }, set_session_user.merge(:user => User.current.id)
    assert_response :not_found
  end

  private

  def create_a_report
    @report = ConfigReport.import(read_json_fixture('reports/empty.json'))
  end
end
