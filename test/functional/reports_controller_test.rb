require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('reports')
    assert_template 'index'
  end

  def test_show
    get :show, {:id => Report.last.id}, set_session_user
    assert_template 'show'
  end

  def test_create_duplicate
    create_a_puppet_transaction_report
    post :create, {:report => @log}, set_session_user
    assert_response :success
    post :create, {:report => @log}, set_session_user
    assert_response :error
  end

  def test_create_valid
    create_a_puppet_transaction_report
    post :create, {:report => @log}, set_session_user
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

    @report = Report.import @log
  end

  def create_a_puppet_transaction_report
    @log = File.read(File.expand_path(File.dirname(__FILE__) + "/../fixtures/report-skipped.yaml"))
  end
end
