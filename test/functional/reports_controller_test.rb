require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    User.current = User.admin
  end
  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns('reports')
    assert_template 'index'
  end

  def test_index_via_json
    get :index, {:format => "json"}, set_session_user
    assert_response :success
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end

  def test_show
    get :show, {:id => Report.last.id}, set_session_user
    assert_template 'show'
  end

  def test_show_last
    get :show, {:id => "last"}, set_session_user
    assert_template 'show'
  end

  def test_show_last_report_for_host
    get :show, {:id => "last", :host_id => Report.first.host.to_param}, set_session_user
    assert_template 'show'
  end

  def test_render_404_when_invalid_report_for_a_host_is_requested
    get :show, {:id => "last", :host_id => "blalala.domain.com"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  def test_create_duplicate
    create_a_puppet_transaction_report
    post :create, {:report => @log, :format => "yml"}, set_session_user
    assert_response :success
    post :create, {:report => @log, :format => "yml"}, set_session_user
    assert_response :error
  end

  def test_create_valid
    create_a_puppet_transaction_report
    post :create, {:report => @log, :format => "yml"}, set_session_user
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

  def user_setup
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should succeed in viewing reports' do
    user_setup
    get :index, {}, set_session_user
    assert_response :success
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to create a report' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should create a report successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to create a report' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with a registered smart proxy and SSL cert should create a report successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy but with an SSL cert should not be able to create a report' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'another.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with an unverified SSL cert should not be able to create a report' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to create a report' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to create reports' do
    User.current = nil
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:report => create_a_puppet_transaction_report, :format => "yml"}
    assert_response :success
  end
end
