require 'test_helper'

class ConfigReportsControllerTest < ActionController::TestCase
  setup do
    User.current = users :admin
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('config_reports')
    assert_template 'index'
  end

  def test_show
    report = FactoryGirl.create(:report)
    get :show, {:id => report.id}, set_session_user
    assert_template 'show'
  end

  def test_show_last
    FactoryGirl.create(:report)
    get :show, {:id => "last"}, set_session_user
    assert_template 'show'
  end

  def test_show_last_report_for_host
    report   = FactoryGirl.create(:report)
    get :show, {:id => "last", :host_id => report.host.to_param}, set_session_user
    assert_template 'show'
  end

  def test_render_404_when_invalid_report_for_a_host_is_requested
    get :show, {:id => "last", :host_id => "blalala.domain.com"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_destroy
    report = FactoryGirl.create(:report)
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
    @report = Report.import JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/report-empty.json")))
  end

  def user_setup
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should succeed in viewing reports' do
    user_setup
    get :index, {}, set_session_user
    assert_response :success
  end
end
