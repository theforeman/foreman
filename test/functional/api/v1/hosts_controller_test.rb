require 'test_helper'

class Api::V1::HostsControllerTest < ActionController::TestCase

  def valid_attrs
    { :name                => 'testhost11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ip                  => '10.0.0.20',
      :mac                 => '52:53:00:1e:85:93',
      :ptable_id           => ptables(:one).id,
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:one).id,
      :compute_resource_id => compute_resources(:one).id,
      :root_pass           => "xybxa6JUkz63w"
    }
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty hosts
  end

  test "should show individual record" do
    get :show, { :id => hosts(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should create host" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, { :host => valid_attrs }
    end
    assert_response :success
    last_host = Host.order('id desc').last
  end

  test "should create host with managed is false if parameter is passed" do
    disable_orchestration
    post :create, { :host => valid_attrs.merge!(:managed => false) }
    assert_response :success
    last_host = Host.order('id desc').last
    assert_equal false, last_host.managed?
  end

  test "should update host" do
    put :update, { :id => hosts(:two).to_param, :host => { } }
    assert_response :success
  end

  test "should destroy hosts" do
    assert_difference('Host.count', -1) do
      delete :destroy, { :id => hosts(:one).to_param }
    end
    assert_response :success
  end

  test "should show status hosts" do
    get :status, { :id => hosts(:one).to_param }
    assert_response :success
  end

  test "should be able to create hosts even when restricted" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, { :host => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the host" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    $debug = true
    get :show, { :id => hosts(:owned_by_restricted).to_param }
    assert_response :success
  end

  test "should allow to update for restricted user who owns the host" do
    disable_orchestration
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, { :id => hosts(:owned_by_restricted).to_param, :host => {} }
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the hosts" do
    assert_difference('Host.count', -1) do
      setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
      delete :destroy, { :id => hosts(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the hosts" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, { :id => hosts(:owned_by_restricted).to_param }
    assert_response :success
  end

  test "should not allow access to a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not list a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :index, {}
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    ids = hosts.map { |hash| hash['host']['id'] }
    refute_includes ids, hosts(:one).id
    assert_includes ids, hosts(:owned_by_restricted).id
  end

  test "should not update host out of users hosts scope" do
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not delete hosts out of users hosts scope" do
    setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    delete :destroy, { :id => hosts(:one).to_param }
    assert_response :not_found
  end

  test "should not show status of hosts out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, { :id => hosts(:one).to_param }
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
    User.current = nil # User.current is admin at this point (from initialize_host)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response :success
    get :show, {:id => host.to_param}
    assert_response :success
  end

end
