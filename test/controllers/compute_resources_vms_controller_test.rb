require 'test_helper'

class ComputeResourcesVmsControllerTest < ActionController::TestCase
  setup do
    @compute_resource = compute_resources(:mycompute)
    @your_compute_resource = compute_resources(:yourcompute)
    get_test_vm
  end

  def setup_user(operation, type = 'compute_resources_vms')
    super(operation, type, "id = #{@compute_resource.id}")
  end

  test "should not get index when not permitted" do
    setup_user "none"
    get :index, {:compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :forbidden
  end

  test "should get index" do
    setup_user "view"
    get :index, {:compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should not show vm JSON when not permitted" do
    setup_user "none"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :forbidden
  end

  test "should not show vm JSON when restricted" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @your_compute_resource.to_param}, set_session_user
    assert_response :not_found
  end

  test "should show vm JSON" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should not show vm when not permitted" do
    setup_user "none"
    get :show, {:id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :forbidden
  end

  test "should not show vm when restricted" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param}, set_session_user
    assert_response :not_found
  end

  test "should show vm" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should not create compute resource when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      attrs = {:name => 'name123', :memory => 128.megabytes, :arch => "i686"}
      post :create, {:vm => attrs, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end
    assert_response :forbidden
  end

  #Broken with Fog.mock! because lib/fog/libvirt/models/compute/volume.rb:41 calls create_volume with the wrong number of arguments
  #Broken before Fog 8d95d5bff223a199d33e297ea21884d8598f6921 because default pool name being "default-pool" and not "default" (with test:///default) triggers an internal bug
  def test_should_create_vm(name = "new_test")
    setup_user "create" do |user|
      user.roles.last.add_permissions! :view_compute_resources
    end
    assert_difference('@compute_resource.vms.count', +1) do
      attrs = {:name => name, :memory => 128.megabytes, :domain_type => "test", :arch => "i686"}
      post :create, {:vm => attrs, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end
    assert_redirected_to compute_resource_vms_path
  end

  test "should not destroy vm when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      delete :destroy, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end

    assert_response :forbidden
  end

  test "should not destroy vm when restricted" do
    setup_user "destroy"
    assert_difference('@your_compute_resource.vms.count', 0) do
      delete :destroy, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param}, set_session_user
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
    @compute_resource.vms.each {|vm| @new_vm = vm if vm.name == "tobedeleted_test"}
    setup_user "destroy"
    assert_difference('@compute_resource.vms.count', -1) do
      delete :destroy, {:id => @new_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end

    assert_redirected_to compute_resource_vms_path
  end

  test "should not power vm when not permitted" do
    setup_user "view"
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user

    assert_response :forbidden
  end

  test "should not power vm when restricted" do
    setup_user "power"
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param}, set_session_user

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

    Fog::Compute::OpenStack::Server.any_instance.expects(:state).returns('ACTIVE').at_least_once
    Fog::Compute::OpenStack::Server.any_instance.expects(:pause).returns(true)
    get :pause, { :format => 'json', :id => @test_vm.id, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_redirected_to compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param, :id => @test_vm.identity)
    Fog.unmock!
  end

  test "should power vm" do
    setup_user "power"

    get_test_vm
    assert @test_vm.ready?
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_redirected_to compute_resource_vm_path(:compute_resource_id => @compute_resource.to_param, :id => @test_vm.identity)
    get_test_vm
    refute @test_vm.ready?

    # Swith it back on for next tests
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
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
    get :power, {:format => 'json', :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_match /Power error/, flash[:error]
    assert_redirected_to @request.env['HTTP_REFERER']
  end

  def get_test_vm
    @test_vm = @compute_resource.vms.find { |vm| vm.name == 'test' }
  end

  def set_session_user
    User.current = users(:admin) unless User.current
    SETTINGS[:login] ? {:user => User.current.id, :expires_at => 5.minutes.from_now} : {}
  end
end
