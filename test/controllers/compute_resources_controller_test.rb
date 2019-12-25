require 'test_helper'
require 'pagelets_test_helper'

class ComputeResourcesControllerTest < ActionController::TestCase
  include PageletsIsolation

  setup do
    @compute_resource = compute_resources(:mycompute)
    @your_compute_resource = compute_resources(:yourcompute)
    @factory_options = :ec2
  end

  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should not get index when not permitted" do
    setup_user "none"
    get :index, session: set_session_user
    assert_response 403
  end

  test "should get index" do
    setup_user "view"
    get :index, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should not get new when not permitted" do
    setup_user "view"
    get :new, session: set_session_user
    assert_response 403
  end

  test "should get new" do
    setup_user "create"
    get :new, session: set_session_user
    assert_response :success
  end

  test "should not create compute resource when not permitted" do
    setup_user "view"
    assert_difference('ComputeResource.unscoped.count', 0) do
      attrs = {:name => "test", :provider => "Libvirt", :url => "qemu://host/system"}
      post :create, params: { :compute_resource => attrs }, session: set_session_user
    end
    assert_response 403
  end

  test "should create compute resource" do
    role = FactoryBot.build(:role)
    role.add_permissions!([:view_locations, :assign_locations, :edit_locations, :view_organizations, :assign_organizations, :edit_organizations])
    setup_user "create", 'compute_resources', ''
    User.current.roles << role
    assert_difference('ComputeResource.unscoped.count', +1) do
      attrs = {:name => "test", :provider => "Libvirt", :url => "qemu://host/system"}
      post :create, params: { :compute_resource => attrs }, session: set_session_user
    end

    assert_redirected_to compute_resource_url(assigns('compute_resource'))
  end

  test "should not show compute resource when not permitted" do
    setup_user "none"
    get :show, params: { :id => @compute_resource.to_param }, session: set_session_user
    assert_response 403
  end

  test "should not show compute resource when restricted" do
    setup_user "view"
    get :show, params: { :id => @your_compute_resource.to_param }, session: set_session_user
    assert_response 404
  end

  test "should show compute resource" do
    setup_user "view"
    get :show, params: { :id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not get edit when not permitted" do
    setup_user "view"
    get :edit, params: { :id => @compute_resource.to_param }, session: set_session_user
    assert_response 403
  end

  test "host update without  password in the params does not erase existing password" do
    old_password = @compute_resource.password
    setup_user "edit"
    put :update, params: { :id => @compute_resource.to_param, :compute_resource => {:name => "editing_self"} }, session: set_session_user
    @compute_resource = ComputeResource.unscoped.find(@compute_resource.id)
    assert_equal old_password, @compute_resource.password
  end

  test 'blank password submitted in compute resource edit form unsets password' do
    setup_user "edit"
    put :update, params: { :id => @compute_resource.to_param, :compute_resource => {:name => "editing_self", :password => ''} }, session: set_session_user
    @compute_resource = ComputeResource.unscoped.find(@compute_resource.id)
    assert @compute_resource.password.empty?
  end

  test "should not get edit when restricted" do
    setup_user "edit"
    get :edit, params: { :id => @your_compute_resource.to_param }, session: set_session_user
    assert_response 404
  end

  test "should get edit" do
    setup_user "edit"
    get :edit, params: { :id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not update compute resource when not permitted" do
    setup_user "view"
    put :update, params: { :id => @compute_resource.to_param, :compute_resource => {:name => "editing_self"} }, session: set_session_user
    assert_response 403
  end

  test "should not update compute resource when restricted" do
    setup_user "edit"
    put :update, params: { :id => @your_compute_resource.to_param, :compute_resource => {:name => "editing_self"} }, session: set_session_user
    assert_response 404
  end

  test "should update compute resource" do
    setup_user "edit"
    put :update, params: { :id => @compute_resource.to_param, :compute_resource => {:name => "editing_self"} }, session: set_session_user
    assert_redirected_to compute_resources_path
  end

  test "should not destroy compute resource when not permitted" do
    setup_user "view"
    assert_difference('ComputeResource.unscoped.count', 0) do
      delete :destroy, params: { :id => @compute_resource.to_param }, session: set_session_user
    end

    assert_response 403
  end

  test "should not destroy compute resource when restricted" do
    setup_user "destroy"
    assert_difference('ComputeResource.unscoped.count', 0) do
      delete :destroy, params: { :id => @your_compute_resource.to_param }, session: set_session_user
    end

    assert_response 404
  end

  test "should destroy compute resource" do
    setup_user "destroy"
    assert_difference('ComputeResource.unscoped.count', -1) do
      delete :destroy, params: { :id => @compute_resource.to_param }, session: set_session_user
    end

    assert_redirected_to compute_resources_path
  end

  context 'search' do
    setup { setup_user 'view' }

    test 'valid fields' do
      get :index, params: { :search => 'name = openstack' }, session: set_session_user
      assert_response :success
      assert flash.empty?
    end

    test 'invalid fields' do
      @request.env['HTTP_REFERER'] = "http://test.host#{compute_resources_path}"
      get :index, params: { :search => 'wrongwrong = centos' }, session: set_session_user
      assert_response :redirect
      assert_redirected_to compute_resources_path
      assert_match /not recognized for searching/, flash[:error]
    end
  end

  context 'vmware' do
    setup do
      @compute_resource = compute_resources(:vmware)
      Fog.mock!
    end

    teardown do
      Fog.unmock!
    end

    test 'resource_pools' do
      resource_pools = ['swimming-pool', 'fishing-pool']
      Foreman::Model::Vmware.any_instance.stubs(:resource_pools).returns(resource_pools)
      get :resource_pools, params: {:id => @compute_resource, :cluster_id => 'my_cluster'}, session: set_session_user, xhr: true
      assert_response :success
      assert_equal(resource_pools, JSON.parse(response.body))
    end

    test 'resource_pools for non-vmware compute resource should return not allowed' do
      compute_resource = compute_resources(:mycompute)
      get :resource_pools, params: {:id => compute_resource, :cluster_id => 'my_cluster'}, session: set_session_user, xhr: true
      assert_response :method_not_allowed
    end

    test 'resource_pools should respond only to ajax call' do
      get :resource_pools, params: { :id => @compute_resource, :cluster_id => 'my_cluster' }, session: set_session_user
      assert_response :method_not_allowed
    end
  end

  context 'compute resource cache' do
    test 'should show refresh-button if supported' do
      compute_resource = compute_resources(:vmware)
      get :show, params: { :id => compute_resource.to_param }, session: set_session_user
      assert_select 'a.btn[href$="/refresh_cache"]'
    end

    test 'should not show refresh-button if not supported' do
      get :show, params: { :id => @compute_resource.to_param }, session: set_session_user
      assert_select 'a.btn[href$="/refresh_cache"]', false
    end

    test 'should refresh the cache' do
      @compute_resource = compute_resources(:vmware)
      put :refresh_cache, params: { :id => @compute_resource.to_param }, session: set_session_user
      assert_redirected_to compute_resource_url(@compute_resource)
      assert_match /Successfully refreshed the cache/, flash[:success]
    end

    test 'should not refresh the cache if unsupported' do
      put :refresh_cache, params: { :id => @compute_resource.to_param }, session: set_session_user
      assert_redirected_to compute_resource_url(@compute_resource)
      assert_match /Cache refreshing is not supported/, flash[:error]
    end
  end

  context 'with pagelets' do
    setup do
      @controller.prepend_view_path File.expand_path('../static_fixtures', __dir__)
      Pagelets::Manager.add_pagelet('compute_resources/show', :main_tabs,
        :name => 'TestTab',
        :id => 'my-special-id',
        :partial => 'views/test')
    end

    test '#new renders a pagelet tab' do
      get :show, params: { :id => @compute_resource.to_param }, session: set_session_user
      assert @response.body.match /id='my-special-id'/
    end
  end

  def set_session_user
    User.current = users(:admin) unless User.current
    {:user => User.current.id, :expires_at => 5.minutes.from_now}
  end

  def setup_user(operation, type = 'compute_resources', condition = nil)
    super(operation, type, condition || "id = #{@compute_resource.id}")
  end
end
