require 'test_helper'

class SmartProxiesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    post :create, {:smart_proxy => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    ProxyAPI::Features.any_instance.stubs(:features => Feature.name_map.keys)
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    SmartProxy.any_instance.stubs(:to_s).returns("puppet")
    post :create, {:smart_proxy => {:name => "MySmartProxy", :url => "http://nowhere.net:8000"}}, set_session_user
    assert_redirected_to smart_proxies_url
  end

  def test_edit
    get :edit, {:id => SmartProxy.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    SmartProxy.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => SmartProxy.first.to_param, :smart_proxy => {:url => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    SmartProxy.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => SmartProxy.unscoped.first,
                  :smart_proxy => {:url => "http://elsewhere.com:8443"}}, set_session_user
    assert_equal "http://elsewhere.com:8443", SmartProxy.unscoped.first.url
    assert_redirected_to smart_proxies_url
  end

  def test_destroy
    proxy = SmartProxy.first
    proxy.subnets.clear
    proxy.domains.clear
    delete :destroy, {:id => proxy}, set_session_user
    assert_redirected_to smart_proxies_url
    assert !SmartProxy.exists?(proxy.id)
  end

  def test_refresh
    proxy = smart_proxies(:one)
    SmartProxy.any_instance.stubs(:associate_features).returns(true)
    post :refresh, {:id => proxy}, set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "No changes found when refreshing features from DHCP Proxy.", flash[:notice]
  end

  def test_refresh_change
    proxy = smart_proxies(:one)
    SmartProxy.any_instance.stubs(:associate_features).returns(true)
    SmartProxy.any_instance.stubs(:features).returns([features(:dns)]).then.returns([features(:dns), features(:tftp)])
    post :refresh, {:id => proxy}, set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "Successfully refreshed features from DHCP Proxy.", flash[:notice]
  end

  def test_refresh_fail
    proxy = smart_proxies(:one)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :base, "Unable to communicate with the proxy: it is down"
    SmartProxy.any_instance.stubs(:errors).returns(errors)
    SmartProxy.any_instance.stubs(:associate_features).returns(true)
    post :refresh, {:id => proxy}, set_session_user
    assert_redirected_to smart_proxies_url
    assert_equal "Unable to communicate with the proxy: it is down", flash[:error]
  end

  test "should search by name" do
    get :index, { :search => "name=\"DNS Proxy\"" }, set_session_user
    assert_response :success
    refute_empty assigns(:smart_proxies)
    assert assigns(:smart_proxies).include?(smart_proxies(:three))
  end

  test "should search by feature" do
    get :index, { :search => "feature=DNS" }, set_session_user
    assert_response :success
    refute_empty assigns(:smart_proxies)
    assert assigns(:smart_proxies).include?(smart_proxies(:three))
  end

  test "smart proxy version succeeded" do
    expected_response = {'version' => '1.11', 'modules' => {'dns' => '1.11'}}
    ProxyStatus::Version.any_instance.stubs(:version).returns(expected_response)
    get :ping, { :id => smart_proxies(:one).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('1.11', show_response['message']['version'])
  end

  test "smart proxy version failed" do
    ProxyStatus::Version.any_instance.stubs(:version).raises(Foreman::Exception, 'Exception message')
    get :ping, { :id => smart_proxies(:one).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['message'])
  end

  test '#show' do
    proxy = smart_proxies(:one)
    get :show, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'show'
  end

  test 'tftp_server should return tftp address' do
    ProxyStatus::TFTP.any_instance.stubs(:server).returns('127.13.0.1')
    get :tftp_server, { :id => smart_proxies(:two).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('127.13.0.1', show_response['message'])
  end

  test 'tftp server should return false if not found' do
    get :tftp_server, { :id => smart_proxies(:one).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/No TFTP feature/, show_response['message'])
  end

  test '#puppet_environments' do
    proxy = smart_proxies(:puppetmaster)
    fake_data = {'env1' => 1, 'special_environment' => 4}
    ProxyStatus::Puppet.any_instance.expects(:environment_stats).returns(fake_data)
    xhr :get, :puppet_environments, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/plugins/_puppet_envs'
    assert @response.body.include?('special_environment')
    assert @response.body.include?('5') #the total is correct
  end

  test '#puppet_dashboard' do
    proxy = smart_proxies(:puppetmaster)
    xhr :get, :puppet_dashboard, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/plugins/_puppet_dashboard'
    assert @response.body.include? 'Latest Events'
  end

  test '#log_pane' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
    {
      'logs' => [{
        "timestamp" => 1453890750.9860077,
        "level" => "DEBUG",
        "message" => "A debug message"
      }]})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :log_pane, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_list'
    assert @response.body.include?('debug message')
  end

  test '#expire_logs' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
    {
      'logs' => [{
        "timestamp" => 1453890750.9860077,
        "level" => "DEBUG",
        "message" => "A debug message"
      }]})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    SmartProxy.any_instance.expects(:expired_logs=).with('42').returns('42')
    xhr :get, :expire_logs, { :id => proxy.id, :from => 42 }, set_session_user
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
          "BMC" => "Initialization error"
        }}})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :failed_modules, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_failed_modules'
    assert @response.body.include?('BMC')
  end

  test '#errors_card' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
    {
      "info" => {
        "failed_modules" => {}
      },
      "logs" => [
        { "timestamp" => 1000, "level" => "INFO", "message" => "Message" },
        { "timestamp" => 1001, "level" => "INFO", "message" => "Message" },
        { "timestamp" => 1002, "level" => "ERROR", "message" => "Message" },
        { "timestamp" => 1003, "level" => "FATAL", "message" => "Message" }
      ]})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :errors_card, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_errors_card'
    assert @response.body.include?('2 log messages')
    assert @response.body.include?('2 error messages')
  end

  test '#errors_card_empty' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
    {
      "info" => {
        "failed_modules" => {}
      },
      "logs" => []})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :errors_card, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_errors_card'
    assert @response.body.include?('pficon-ok')
    assert @response.body.include?('0 log messages')
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
          "Puppet" => "Another message"
        }
      },
      "logs" => []})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :modules_card, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_modules_card'
    assert @response.body.include?('4 active features')
    assert @response.body.include?('Failed features: BMC, Puppet')
  end

  test '#modules_card_empty' do
    proxy = smart_proxies(:logs)
    fake_data = ::SmartProxies::LogBuffer.new(
    {
      "info" => {
        "failed_modules" => {}
      },
      "logs" => []})
    ProxyStatus::Logs.any_instance.expects(:logs).returns(fake_data)
    xhr :get, :modules_card, { :id => proxy.id }, set_session_user
    assert_response :success
    assert_template 'smart_proxies/logs/_modules_card'
    assert @response.body.include?('pficon-ok')
    refute @response.body.include?('BMC')
  end
end
