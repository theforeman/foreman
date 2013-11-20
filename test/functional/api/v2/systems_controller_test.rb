require 'test_helper'

class Api::V2::SystemsControllerTest < ActionController::TestCase

  def valid_attrs
    { :name                => 'testsystem11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ip                  => '10.0.0.20',
      :mac                 => '52:53:00:1e:85:93',
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:one).id,
      :compute_resource_id => compute_resources(:one).id
    }
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:systems)
    systems = ActiveSupport::JSON.decode(@response.body)
    assert !systems.empty?
  end

  test "should show individual record" do
    get :show, { :id => systems(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create system" do
    disable_orchestration
    assert_difference('System.count') do
      post :create, { :system => valid_attrs }
    end
    assert_response :success
    last_system = System.order('id desc').last
  end

  test "should create system with managed is false if parameter is passed" do
    disable_orchestration
    post :create, { :system => valid_attrs.merge!(:managed => false) }
    assert_response :success
    last_system = System.order('id desc').last
    assert_equal false, last_system.managed?
  end

  test "should update system" do
    put :update, { :id => systems(:two).to_param, :system => { } }
    assert_response :success
  end

  test "should destroy systems" do
    assert_difference('System.count', -1) do
      delete :destroy, { :id => systems(:one).to_param }
    end
    assert_response :success
  end

  test "should show status systems" do
    get :status, { :id => systems(:one).to_param }
    assert_response :success
  end

  test "should be able to create systems even when restricted" do
    disable_orchestration
    assert_difference('System.count') do
      post :create, { :system => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the system" do
    as_user :restricted do
      get :show, { :id => systems(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should allow to update for restricted user who owns the system" do
    disable_orchestration
    as_user :restricted do
      put :update, { :id => systems(:owned_by_restricted).to_param, :system => {} }
    end
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the systems" do
    assert_difference('System.count', -1) do
      as_user :restricted do
        delete :destroy, { :id => systems(:owned_by_restricted).to_param }
      end
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the systems" do
    as_user :restricted do
      get :status, { :id => systems(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should not allow access to a system out of users systems scope" do
    as_user :restricted do
      get :show, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not list a system out of users systems scope" do
    as_user :restricted do
      get :index, {}
    end
    assert_response :success
    systems = ActiveSupport::JSON.decode(@response.body)
    ids = systems.map { |hash| hash['system']['id'] }
    assert !ids.include?(systems(:one).id)
    assert ids.include?(systems(:owned_by_restricted).id)
  end

  test "should not update system out of users systems scope" do
    as_user :restricted do
      put :update, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not delete systems out of users systems scope" do
    as_user :restricted do
      delete :destroy, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not show status of systems out of users systems scope" do
    as_user :restricted do
      get :status, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  def set_remote_user_to user
    @request.env['REMOTE_USER'] = user.login
  end

  test "when REMOTE_USER is provided and both authorize_login_delegation{,_api}
        are set, authentication should succeed w/o valid session cookies" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = true
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_system)
    system = System.first
    get :show, {:id => system.to_param, :format => 'json'}
    assert_response :success
    get :show, {:id => system.to_param}
    assert_response :success
  end

  def fact_json
    @json  ||= JSON.parse(Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.json").read)
  end

  test "should run puppet for specific system" do
    User.current=nil
    ProxyAPI::Puppet.any_instance.stubs(:run).returns(true)
    get :puppetrun, { :id => systems(:one).to_param }
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_without_certname
    User.current=nil
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}, set_session_user
    assert_response :success
  end

  def test_create_valid_node_from_json_facts_object_with_certname
    User.current=nil
    systemname = fact_json['name']
    certname = fact_json['certname']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :certname => certname, :facts => facts}, set_session_user
    assert_response :success
  end

  def test_create_invalid
    User.current=nil
    systemname = fact_json['name']
    facts    = fact_json['facts'].except('operatingsystem')
    post :facts, {:name => systemname, :facts => facts}, set_session_user
    assert_response :unprocessable_entity
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_nil @controller.detected_proxy
    assert_response :success
  end

  test 'systems with a registered smart proxy on should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    proxy = smart_proxies(:puppetmaster)
    system   = URI.parse(proxy.url).host
    Resolv.any_instance.stubs(:getnames).returns([system])
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_equal proxy, @controller.detected_proxy
    assert_response :success
  end

  test 'systems without a registered smart proxy on should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.system'])
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :forbidden
  end

  test 'systems with a registered smart proxy and SSL cert should import facts successfully' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :success
  end

  test 'systems without a registered smart proxy but with an SSL cert should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=another.system'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :forbidden
  end

  test 'systems with an unverified SSL cert should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=secure.system'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :forbidden
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to import facts' do
    User.current = users(:one) #use an unprivileged user, not apiadmin
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}
    assert_response :success
  end

  test "when a bad :type is requested, :unprocessable_entity is returned" do
    User.current=nil
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts, :type => "System::Invalid"}, set_session_user
    assert_response :unprocessable_entity
    assert_equal JSON.parse(response.body)['message'], 'ERF51-7324: A problem occurred when detecting system type: uninitialized constant System::Invalid'
  end

  test "when the imported system failed to save, :unprocessable_entity is returned" do
    System::Managed.any_instance.stubs(:save).returns(false)
    errors = ActiveModel::Errors.new(System::Managed.new)
    errors.add :foo, 'A stub failure'
    System::Managed.any_instance.stubs(:errors).returns(errors)
    User.current=nil
    systemname = fact_json['name']
    facts    = fact_json['facts']
    post :facts, {:name => systemname, :facts => facts}, set_session_user
    assert_response :unprocessable_entity
    assert_equal 'A stub failure', JSON.parse(response.body)['system']['errors']['foo'].first
  end

  context 'BMC proxy operations' do
    setup :initialize_proxy_ops

    def initialize_proxy_ops
      User.current = users(:apiadmin)
      nics(:bmc).update_attribute(:system_id, systems(:one).id)
    end

    test "power call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
      put :power, { :id => systems(:one).to_param, :power_action => 'status' }
      assert_response :success
      assert @response.body =~ /on/
    end

    test "wrong power call fails gracefully" do
      put :power, { :id => systems(:one).to_param, :power_action => 'wrongmethod' }
      assert_response 422
      assert @response.body =~ /Available methods are/
    end

    test "boot call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:boot).with(:function => 'bootdevice', :device => 'bios').
                                              returns( { "action" => "bios", "result" => true } .to_json)
      put :boot, { :id => systems(:one).to_param, :device => 'bios' }
      assert_response :success
      assert @response.body =~ /true/
    end

    test "wrong boot call to interface fails gracefully" do
      put :boot, { :id => systems(:one).to_param, :device => 'wrongbootdevice' }
      assert_response 422
      assert @response.body =~ /Available devices are/
    end

  end

end
