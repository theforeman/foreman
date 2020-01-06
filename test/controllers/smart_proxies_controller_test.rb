require 'test_helper'

class SmartProxiesControllerTest < ActionController::TestCase
  basic_pagination_rendered_test
  basic_pagination_per_page_test

  setup do
    stub_smart_proxy_v2_features
  end

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :smart_proxy => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    SmartProxy.any_instance.stubs(:to_s).returns("puppet")
    post :create, params: { :smart_proxy => {:name => "MySmartProxy", :url => "http://nowhere.net:8000"} }, session: set_session_user
    assert_redirected_to smart_proxies_url
  end

  def test_edit
    get :edit, params: { :id => SmartProxy.first }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => SmartProxy.first.to_param, :smart_proxy => {:url => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => SmartProxy.unscoped.first,
                           :smart_proxy => {:url => "http://elsewhere.com:8443"} }, session: set_session_user
    assert_equal "http://elsewhere.com:8443", SmartProxy.unscoped.first.url
    assert_redirected_to smart_proxies_url
  end

  def test_destroy
    proxy = SmartProxy.first
    proxy.subnets.clear
    proxy.domains.clear
    delete :destroy, params: { :id => proxy }, session: set_session_user
    assert_redirected_to smart_proxies_url
    assert !SmartProxy.exists?(proxy.id)
  end

  def test_refresh
    proxy = smart_proxies(:one)
    SmartProxy.any_instance.stubs(:feature_details).returns(:dns => {})
    post :refresh, params: { :id => proxy }, session: set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "No changes found when refreshing features from DHCP Proxy.", flash[:success]
  end

  def test_refresh_change
    proxy = smart_proxies(:one)
    SmartProxy.any_instance.stubs(:feature_details).returns(:dns => {}).then.returns(:dns => {}, :tftp => {})
    post :refresh, params: { :id => proxy }, session: set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "Successfully refreshed features from DHCP Proxy.", flash[:success]
  end

  def test_refresh_fail
    proxy = smart_proxies(:one)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :base, "Unable to communicate with the proxy: it is down"
    SmartProxy.any_instance.stubs(:errors).returns(errors)
    post :refresh, params: { :id => proxy }, session: set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "Unable to communicate with the proxy: it is down", flash[:error]
  end

  test "should search by name" do
    get :index, params: { :search => "name=\"DNS Proxy\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:smart_proxies)
    assert assigns(:smart_proxies).include?(smart_proxies(:three))
  end

  test "should search by feature" do
    get :index, params: { :search => "feature=DNS" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:smart_proxies)
    assert assigns(:smart_proxies).include?(smart_proxies(:three))
  end

  test "smart proxy version succeeded" do
    expected_response = {'version' => '1.11', 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('1.11', show_response['message']['version'])
  end

  test "smart proxy version failed" do
    ProxyStatus::Version.any_instance.stubs(:version).raises(Foreman::Exception, 'Exception message')
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['message'])
  end

  test "smart proxy version mismatched" do
    expected_response = {'version' => '1.11', 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/versions do not match/, show_response['message']['warning']['message'])
  end

  test "smart proxy version with different tags matched" do
    expected_response = {'version' => "#{Foreman::Version.new.notag}-testtag", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_nil show_response['message']['warning']
  end

  test "smart proxy version with different z matched" do
    foreman_version = Foreman::Version.new
    foreman_x, foreman_y, foreman_z = foreman_version.major.to_i, foreman_version.minor.to_i, foreman_version.build.to_i
    expected_response = {'version' => "#{foreman_x}.#{foreman_y}.#{foreman_z + 1}", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_nil show_response['message']['warning']
  end

  test "smart proxy version with next y matched" do
    foreman_version = Foreman::Version.new
    foreman_x, foreman_y, foreman_z = foreman_version.major.to_i, foreman_version.minor.to_i, foreman_version.build.to_i
    expected_response = {'version' => "#{foreman_x}.#{foreman_y + 1}.#{foreman_z}", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_nil show_response['message']['warning']
  end

  test "smart proxy version with previous y warns" do
    foreman_version = Foreman::Version.new
    foreman_x, foreman_y, foreman_z = foreman_version.major.to_i, foreman_version.minor.to_i, foreman_version.build.to_i

    # fix for 1.25 => 2.0 rename
    if foreman_y == 0
      foreman_x -= 1
      foreman_y = 25
    end

    expected_response = {'version' => "#{foreman_x}.#{foreman_y - 1}.#{foreman_z}", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/versions do not match/, show_response['message']['warning']['message'])
  end

  test "smart proxy version with y + 2 warns" do
    foreman_version = Foreman::Version.new
    foreman_x, foreman_y, foreman_z = foreman_version.major.to_i, foreman_version.minor.to_i, foreman_version.build.to_i
    expected_response = {'version' => "#{foreman_x}.#{foreman_y + 2}.#{foreman_z}", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/versions do not match/, show_response['message']['warning']['message'])
  end

  test "smart proxy version with different x warns" do
    foreman_version = Foreman::Version.new
    foreman_x, foreman_y, foreman_z = foreman_version.major.to_i, foreman_version.minor.to_i, foreman_version.build.to_i
    expected_response = {'version' => "#{foreman_x - 1}.#{foreman_y}.#{foreman_z}", 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/versions do not match/, show_response['message']['warning']['message'])
  end

  test '#show' do
    proxy = smart_proxies(:one)
    get :show, params: { :id => proxy.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  test 'tftp_server should return tftp address' do
    ProxyStatus::TFTP.any_instance.stubs(:server).returns('127.13.0.1')
    get :tftp_server, params: { :id => smart_proxies(:two).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('127.13.0.1', show_response['message'])
  end

  test 'tftp server should return false if not found' do
    get :tftp_server, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/No TFTP feature/, show_response['message'])
  end

  test '#puppet_environments' do
    proxy = smart_proxies(:puppetmaster)
    fake_data = {'env1' => 1, 'special_environment' => 4}
    ProxyStatus::Puppet.any_instance.expects(:environment_stats).returns(fake_data)
    get :puppet_environments, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/plugins/_puppet_envs'
    assert @response.body.include?('special_environment')
    assert @response.body.include?('5') # the total is correct
  end

  test '#puppet_dashboard' do
    proxy = smart_proxies(:puppetmaster)
    get :puppet_dashboard, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/plugins/_puppet_dashboard'
    assert @response.body.include? 'Latest Events'
  end

  test '#log_pane' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        'logs' => [
          {
            "timestamp" => 1453890750.9860077,
            "level"     => "DEBUG",
            "message"   => "A debug message",
          },
        ],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :log_pane, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_list'
    assert @response.body.include?('debug message')
  end

  test '#expire_logs' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        'logs' => [
          {
            "timestamp" => 1453890750.9860077,
            "level"     => "DEBUG",
            "message"   => "A debug message",
          },
        ],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    SmartProxy.any_instance.expects(:expired_logs=).with('42').returns('42')
    get :expire_logs, params: { :id => proxy.id, :from => 42 }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_list'
    assert @response.body.include?('debug message')
  end

  test '#failed_modules' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        'info' => {
          "failed_modules" => {
            "BMC" => "Initialization error",
          },
        },
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :failed_modules, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_failed_modules'
    assert @response.body.include?('BMC')
  end

  test '#errors_card' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        "info" => {
          "failed_modules" => {},
        },
        "logs" => [
          { "timestamp" => 1000, "level" => "INFO", "message" => "Message" },
          { "timestamp" => 1001, "level" => "INFO", "message" => "Message" },
          { "timestamp" => 1002, "level" => "ERROR", "message" => "Message" },
          { "timestamp" => 1003, "level" => "FATAL", "message" => "Message" },
        ],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :errors_card, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_errors_card'
    assert @response.body.include?('2 Log Messages')
    assert @response.body.include?('2 error messages')
  end

  test '#errors_card_empty' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        "info" => {
          "failed_modules" => {},
        },
        "logs" => [],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :errors_card, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_errors_card'
    assert @response.body.include?('pficon-ok')
    assert @response.body.include?('0 Log Messages')
    refute @response.body.include?('warning message')
    refute @response.body.include?('error message')
  end

  test '#modules_card' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        "info" => {
          "failed_modules" => {
            "BMC" => "Message",
            "Puppet" => "Another message",
          },
        },
        "logs" => [],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :modules_card, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_modules_card'
    assert @response.body.include?('4 Active Features')
    assert @response.body.include?('Failed features: BMC, Puppet')
  end

  test '#modules_card_empty' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
      {
        "info" => {
          "failed_modules" => {},
        },
        "logs" => [],
      }
    )
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    get :modules_card, params: { :id => proxy.id }, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'smart_proxies/logs/_modules_card'
    assert @response.body.include?('pficon-ok')
    refute @response.body.include?('BMC')
  end
end
