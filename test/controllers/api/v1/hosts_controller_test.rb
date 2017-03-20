require 'test_helper'
require 'controllers/shared/pxe_loader_test'

class Api::V1::HostsControllerTest < ActionController::TestCase
  include ::PxeLoaderTest

  def setup
    @host = FactoryBot.create(:host)
    @ptable = FactoryBot.create(:ptable)
    @ptable.operatingsystems = [ Operatingsystem.find_by_name('Redhat') ]
  end

  def basic_attrs
    { :name                => 'testhost11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ptable_id           => @ptable.id,
      :medium_id           => media(:one).id,
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:puppetmaster).id,
      :compute_resource_id => compute_resources(:one).id,
      :root_pass           => "xybxa6JUkz63w",
      :location_id         => taxonomies(:location1).id,
      :organization_id     => taxonomies(:organization1).id
    }
  end

  def valid_attrs
    net_attrs = {
      :ip  => '10.0.0.20',
      :mac => '52:53:00:1e:85:93'
    }
    basic_attrs.merge(net_attrs)
  end

  def valid_attrs_with_root(extra_attrs = {})
    { :host => valid_attrs.merge(extra_attrs) }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty hosts
  end

  test "should show individual record" do
    get :show, params: { :id => @host.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should create host" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs }
    end
    assert_response :success
  end

  test "should create host with host_parameters_attributes" do
    disable_orchestration
    Foreman::Deprecation.expects(:api_deprecation_warning).with('Field host_parameters_attributes.nested ignored')
    assert_difference('Host.count') do
      attrs = [{"name" => "compute_resource_id", "value" => "1", "nested" => "true"}]
      post :create, params: { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
  end

  test "should create host with host_parameters_attributes sent in a hash" do
    disable_orchestration
    Foreman::Deprecation.expects(:api_deprecation_warning).with('Field host_parameters_attributes.nested ignored')
    assert_difference('Host.count') do
      attrs = {"0" => {"name" => "compute_resource_id", "value" => "1", "nested" => "true"}}
      post :create, params: { :host => valid_attrs.merge(:host_parameters_attributes => attrs) }
    end
    assert_response :created
  end

  test "should create host with managed is false if parameter is passed" do
    disable_orchestration
    post :create, params: { :host => valid_attrs.merge!(:managed => false) }
    assert_response :success
    last_host = Host.order('id desc').last
    assert_equal false, last_host.managed?
  end

  test "should update host" do
    put :update, params: { :id => @host.to_param, :host => { :name => 'testhost1435' } }
    assert_response :success
  end

  test "should destroy hosts" do
    assert_difference('Host.count', -1) do
      delete :destroy, params: { :id => @host.to_param }
    end
    assert_response :success
  end

  test "should show status hosts" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with(regexp_matches(%r{/status route is deprecated}))
    get :status, params: { :id => @host.to_param }
    assert_response :success
  end

  test "should be able to create hosts even when restricted" do
    disable_orchestration
    assert_difference('Host.count') do
      post :create, params: { :host => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the host" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :show, params: { :id => host.to_param }
    assert_response :success
  end

  test "should allow to update for restricted user who owns the host" do
    disable_orchestration
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    put :update, params: { :id => host.to_param, :host => {:name => 'testhost1435'} }
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the hosts" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    assert_difference('Host.count', -1) do
      setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
      delete :destroy, params: { :id => host.to_param }
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the hosts" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    Foreman::Deprecation.expects(:api_deprecation_warning).with(regexp_matches(%r{/status route is deprecated}))
    get :status, params: { :id => host.to_param }
    assert_response :success
  end

  test "should not allow access to a host out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :show, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not list a host out of users hosts scope" do
    host = FactoryBot.create(:host, :owner => users(:scoped), :organization => taxonomies(:organization1), :location => taxonomies(:location1))
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:scoped).id}", :scoped
    get :index
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    ids = hosts.map { |hash| hash['host']['id'] }
    refute_includes ids, @host.id
    assert_includes ids, host.id
  end

  test "should not update host out of users hosts scope" do
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    put :update, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not delete hosts out of users hosts scope" do
    setup_user 'destroy', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    delete :destroy, params: { :id => @host.to_param }
    assert_response :not_found
  end

  test "should not show status of hosts out of users hosts scope" do
    setup_user 'view', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    get :status, params: { :id => @host.to_param }
    assert_response :not_found
  end

  def set_remote_user_to(user)
    @request.env['REMOTE_USER'] = user.login
  end

  test "when REMOTE_USER is provided and both authorize_login_delegation{,_api}
        are set, authentication should succeed w/o valid session cookies" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = true
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_host)
    host = Host.first
    get :show, params: { :id => host.to_param, :format => 'json' }
    assert_response :success
    get :show, params: { :id => host.to_param }
    assert_response :success
  end

  private

  def last_record
    Host.unscoped.order(:id).last
  end
end
