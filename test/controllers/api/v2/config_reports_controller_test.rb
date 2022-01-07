require 'test_helper'
require 'controllers/shared/report_host_permissions_test'

class Api::V2::ConfigReportsControllerTest < ActionController::TestCase
  include ::ReportHostPermissionsTest

  describe "Non Admin User" do
    def setup
      User.current = users(:one) # use an unprivileged user, not apiadmin
    end

    def create_a_puppet_transaction_report
      @log ||= read_json_fixture('reports/empty.json')
    end

    def test_create_valid
      User.current = nil
      post :create, params: { :config_report => create_a_puppet_transaction_report }, session: set_session_user
      assert_response :success
    end

    def test_create_invalid
      User.current = nil
      post :create, params: { :config_report => ["not a hash", "throw an error"] }, session: set_session_user
      assert_response :unprocessable_entity
    end

    def test_create_duplicate
      User.current = nil
      post :create, params: { :config_report => create_a_puppet_transaction_report }, session: set_session_user
      assert_response :success
      post :create, params: { :config_report => create_a_puppet_transaction_report }, session: set_session_user
      assert_response :unprocessable_entity
    end

    test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = false
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_nil @controller.detected_proxy
      assert_response :created
    end

    test 'hosts with a registered smart proxy on should create a report successfully' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = false

      stub_smart_proxy_v2_features
      proxy = smart_proxies(:puppetmaster)
      as_admin { proxy.update_attribute(:url, 'http://configreports.foreman') }
      host = URI.parse(proxy.url).host
      Resolv.any_instance.stubs(:getnames).returns([host])
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_equal proxy, @controller.detected_proxy
      assert_response :created
    end

    test 'hosts without a registered smart proxy on should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = false

      Resolv.any_instance.stubs(:getnames).returns(['another.host'])
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :forbidden
    end

    test 'hosts with a registered smart proxy and SSL cert should create a report successfully' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :created
    end

    test 'hosts without a registered smart proxy but with an SSL cert should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :forbidden
    end

    test 'hosts with an unverified SSL cert should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
      @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :forbidden
    end

    test 'when "require_ssl_smart_proxies" and "require_ssl" are true, HTTP requests should not be able to create a report' do
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true
      SETTINGS[:require_ssl] = true

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :redirect
    end

    test 'when "require_ssl_smart_proxies" is true and "require_ssl" is false, HTTP requests should be able to create reports' do
      # since require_ssl_smart_proxies is only applicable to HTTPS connections, both should be set
      Setting[:restrict_registered_smart_proxies] = true
      Setting[:require_ssl_smart_proxies] = true
      SETTINGS[:require_ssl] = false

      Resolv.any_instance.stubs(:getnames).returns(['else.where'])
      post :create, params: { :config_report => create_a_puppet_transaction_report }
      assert_response :created
    end
  end

  test "should get index" do
    FactoryBot.create(:config_report)
    get :index
    assert_response :success
    assert_not_nil assigns(:config_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports['results'].empty?
  end

  context "with organization given" do
    let(:config_report_org) { Organization.first }
    let(:config_report_loc) { Location.first }
    let(:reporting_host) do
      FactoryBot.create(:host, :location => config_report_loc, :organization => config_report_org)
    end
    let(:config_report) do
      FactoryBot.create(:config_report, :host => reporting_host)
    end

    test "should get config reports in organization" do
      config_report.save!
      get :index, params: { :organization_id => config_report_org.id }
      assert_response :success
      assert_not_nil assigns(:config_reports)
      reports = ActiveSupport::JSON.decode(@response.body)
      assert !reports['results'].empty?
    end
  end

  test "should show individual record" do
    report = FactoryBot.create(:config_report)
    get :show, params: { :id => report.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should destroy report" do
    report = FactoryBot.create(:config_report)
    assert_difference('ConfigReport.count', -1) do
      delete :destroy, params: { :id => report.to_param }
    end
    assert_response :success
    refute Report.unscoped.find_by_id(report.id)
  end

  test "should get reports for given host only" do
    report = FactoryBot.create(:config_report)
    get :index, params: { :host_id => report.host.to_param }
    assert_response :success
    assert_not_nil assigns(:config_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports['results'].empty?
    assert_equal 1, reports['results'].count
  end

  test "should return empty result for host with no reports" do
    host = FactoryBot.create(:host)
    get :index, params: { :host_id => host.to_param }
    assert_response :success
    assert_not_nil assigns(:config_reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert reports['results'].empty?
    assert_equal 0, reports['results'].count
  end

  test "should get last report" do
    reports = FactoryBot.create_list(:config_report, 5)
    get :last, params: set_session_user
    assert_response :success
    assert_not_nil assigns(:config_report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
    assert_equal reports.last, ConfigReport.find(report['id'])
  end

  test "should get last report for given host only" do
    main_report = FactoryBot.create(:config_report)
    FactoryBot.create_list(:config_report, 5)
    get :last, params: { :host_id => main_report.host.to_param }, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:config_report)
    report = ActiveSupport::JSON.decode(@response.body)
    assert !report.empty?
    assert_equal main_report, Report.find(report['id'])
  end

  test "should give error if no last report for given host" do
    host = FactoryBot.create(:host)
    get :last, params: { :host_id => host.to_param }
    assert_response :not_found
  end

  test 'cannot view the last report without hosts view permission' do
    report = FactoryBot.create(:report)
    setup_user('view', 'config_reports')
    get :last, params: { :host_id => report.host.id }, session: set_session_user.merge(:user => User.current.id)
    assert_response :not_found
  end
end
