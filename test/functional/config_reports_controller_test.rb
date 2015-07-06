require 'test_helper'
require 'functional/shared/report_host_permissions_test'

class ConfigReportsControllerTest < ActionController::TestCase
  include ::ReportHostPermissionsTest

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('config_reports')
    assert_template 'index'
  end

  def test_show
    report = FactoryGirl.create(:config_report)
    get :show, {:id => report.id}, set_session_user
    assert_template 'show'
  end

  test '404 on show when id is blank' do
    get :show, {:id => ' '}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last
    FactoryGirl.create(:config_report)
    get :show, {:id => "last"}, set_session_user
    assert_template 'show'
  end

  test '404 on last when no reports available' do
    get :show, { :id => 'last', :host_id => FactoryGirl.create(:host) }, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_show_last_report_for_host
    report   = FactoryGirl.create(:config_report)
    get :show, {:id => "last", :host_id => report.host.to_param}, set_session_user
    assert_template 'show'
  end

  def test_render_404_when_invalid_report_for_a_host_is_requested
    get :show, {:id => "last", :host_id => "blalala.domain.com"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_destroy
    report = FactoryGirl.create(:config_report)
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
    report = FactoryGirl.create(:config_report)
    get :show, { :id => 'last', :host_id => report.host.id }, set_session_user.merge(:user => User.current)
    assert_response :not_found
  end

  private

  def create_a_report
    @report = ConfigReport.import JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/report-empty.json")))
  end
end
