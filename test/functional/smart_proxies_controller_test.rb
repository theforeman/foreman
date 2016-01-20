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
    put :update, {:id => SmartProxy.first,:smart_proxy => {:url => "http://elsewhere.com:8443"}}, set_session_user
    assert_equal "http://elsewhere.com:8443", SmartProxy.first.url
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
end
