require 'test_helper'

class ComputeResourcesVmsControllerTest < ActionController::TestCase
  setup do
    @compute_resource = compute_resources(:mycompute)
    @your_compute_resource = compute_resources(:yourcompute)
    get_test_vm
  end

  def setup_user(operation, type = 'compute_resources_vms', search = nil)
    search ||= "id = #{@compute_resource.id}"
    super(operation, type, search)
  end

  test "should not get index when not permitted" do
    setup_user "none"
    get :index, params: { :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :forbidden
  end

  test "should get index" do
    setup_user "view"
    get :index, params: { :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should not show vm JSON when not permitted" do
    setup_user "none"
    get :show, params: { :id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :forbidden
  end

  test "should not show vm JSON when restricted" do
    setup_user "view"
    get :show, params: { :id => @test_vm.uuid, :format => "json", :compute_resource_id => @your_compute_resource.to_param }, session: set_session_user
    assert_response :not_found
  end

  test "should show vm JSON" do
    setup_user "view"
    get :show, params: { :id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not show vm when not permitted" do
    setup_user "none"
    get :show, params: { :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :forbidden
  end

  test "should not show vm when restricted" do
    setup_user "view"
    get :show, params: { :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param }, session: set_session_user
    assert_response :not_found
  end

  test "should show vm" do
    setup_user "view"
    get :show, params: { :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not create compute resource when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      attrs = {:name => 'name123', :memory => 128.megabytes, :arch => "i686"}
      post :create, params: { :vm => attrs, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    end
    assert_response :forbidden
  end

  # Broken with Fog.mock! because lib/fog/libvirt/models/compute/volume.rb:41 calls create_volume with the wrong number of arguments
  # Broken before Fog 8d95d5bff223a199d33e297ea21884d8598f6921 because default pool name being "default-pool" and not "default" (with test:///default) triggers an internal bug
  def test_should_create_vm(name = "new_test")
    setup_user "create" do |user|
      user.roles.last.add_permissions! :view_compute_resources
    end
    assert_difference('@compute_resource.vms.count', +1) do
      attrs = {:name => name, :memory => 128.megabytes, :domain_type => "test", :arch => "i686"}
      post :create, params: { :vm => attrs, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    end
    assert_redirected_to compute_resource_vms_path
  end

  test "should not destroy vm when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      delete :destroy, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    end

    assert_response :forbidden
  end

  test "should not destroy vm when restricted" do
    setup_user "destroy"
    assert_difference('@your_compute_resource.vms.count', 0) do
      delete :destroy, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param }, session: set_session_user
    end

    assert_response :not_found
  end

  test "should destroy vm" do
    # We have to work on a new vm, instead of deleting the test one,
    # which is automatically created for each new connection.
    # Another solution would be to disconnect between each test,
    # but the only way to do this is to tweak with Thread.current["test:///default]...
    # Create the new vm first
    test_should_create_vm "tobedeleted_test"
    # Find it
    @compute_resource.vms.each { |vm| @new_vm = vm if vm.name == "tobedeleted_test" }
    setup_user "destroy"
    assert_difference('@compute_resource.vms.count', -1) do
      delete :destroy, params: { :id => @new_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    end

    assert_redirected_to compute_resource_vms_path
  end

  test "should not power vm when not permitted" do
    setup_user "view"
    get :power, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user

    assert_response :forbidden
  end

  test "should not power vm when restricted" do
    setup_user "power"
    get :power, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param }, session: set_session_user

    assert_response :not_found
  end

  test "should pause openstack vm" do
    Fog.mock!
    @compute_resource = compute_resources(:openstack)
    @compute_resource.tenant = 'personal'
    Fog.credentials[:openstack_auth_url] = @compute_resource.url
    @test_vm = @compute_resource.vms.create({:flavor_ref => 2, :name => 'test', :image_ref => 2})
    as_admin { @compute_resource.save }
    setup_user "power"
    @compute_resource.organizations = User.current.organizations
    @compute_resource.locations = User.current.locations

    Fog::OpenStack::Compute::Server.any_instance.expects(:state).returns('ACTIVE').at_least_once
    Fog::OpenStack::Compute::Server.any_instance.expects(:pause).returns(true)
    get :pause, params: { :format => 'json', :id => @test_vm.id, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_redirected_to compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param, :id => @test_vm.identity)
    Fog.unmock!
  end

  test "should power vm" do
    setup_user "power"

    get_test_vm
    assert @test_vm.ready?
    get :power, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_redirected_to compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param, :id => @test_vm.identity)
    get_test_vm
    refute @test_vm.ready?

    # Swith it back on for next tests
    get :power, params: { :format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_redirected_to compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param, :id => @test_vm.identity)
    get_test_vm
    assert @test_vm.ready?
  end

  test 'errors coming from the vm should be displayed' do
    setup_user 'power'

    get_test_vm
    @test_vm.class.any_instance.expects(:stop).raises(Fog::Errors::Error.new('Power error'))
    @request.env['HTTP_REFERER'] = compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param,
                                                            :id => @test_vm.identity)
    get :power, params: { :format => 'json', :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param }, session: set_session_user
    assert_match /Power error/, flash[:error]
    assert_redirected_to @request.env['HTTP_REFERER']
  end

  context '#import' do
    setup { Fog.mock! }
    teardown { Fog.unmock! }

    let(:compute_resource) do
      orgs = User.current.organizations
      locs = User.current.locations
      as_admin do
        FactoryBot.create(:compute_resource, :vmware, :uuid => 'Solutions',
                           :organizations => orgs, :locations => locs)
      end
    end

    test 'imports a host' do
      setup_user('create', 'hosts', '')
      setup_user('view', 'compute_resources_vms', "id = #{compute_resource.id}")
      get :import, params: {:compute_resource_id => compute_resource.id, :id => '5032c8a5-9c5e-ba7a-3804-832a03e16381'}, session: set_session_user
      assert assigns(:host)
      assert_template 'compute_resources_vms/import'
    end

    test 'should not import when not permitted to view compute_resource' do
      setup_user('none')
      get :import, params: {:compute_resource_id => compute_resource.id, :id => '5032c8a5-9c5e-ba7a-3804-832a03e16381'}, session: set_session_user
      assert_response :forbidden
    end

    test 'should not import when not permitted to create hosts' do
      setup_user('view', 'compute_resources_vms', "id = #{compute_resource.id}")
      get :import, params: {:compute_resource_id => compute_resource.id, :id => '5032c8a5-9c5e-ba7a-3804-832a03e16381'}, session: set_session_user
      assert_response :forbidden
    end
  end

  private

  def get_test_vm
    @test_vm = @compute_resource.vms.find { |vm| vm.name == 'test' }
  end

  def set_session_user
    User.current = users(:admin) unless User.current
    {:user => User.current.id, :expires_at => 5.minutes.from_now}
  end
end
