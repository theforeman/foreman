require 'test_helper'

class ComputeResourcesVmsControllerTest < ActionController::TestCase
  setup do
#    Fog.mock!
    @compute_resource = compute_resources(:mycompute)
    @your_compute_resource = compute_resources(:yourcompute)
    get_test_vm
  end

  teardown do
#    Fog.unmock!
  end

  test "should not get index when not permitted" do
    setup_user "none"
    get :index, {:compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should get index" do
    setup_user "view"
    get :index, {:format => "json", :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
    logger.info @response.body
    computes = ActiveSupport::JSON.decode(@response.body)
    assert !computes.empty?
    assert computes.is_a?(Array)
    assert computes.length >= 1
    assert_not_nil computes.index{|vm| vm["uuid"] == @test_vm.uuid}
  end

  test "should not show vm when not permitted" do
    setup_user "none"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should not show vm when restricted" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @your_compute_resource.to_param}, set_session_user
    assert_response 403
  end

  test "should show vm" do
    setup_user "view"
    get :show, {:id => @test_vm.uuid, :format => "json", :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_response :success
  end

  test "should not create compute resource when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      attrs = {:name => name, :memory => 128*1024*1024, :arch => "i686"}
      post :create, {:vm => attrs, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end
    assert_response 403
  end

  #Broken with Fog.mock! because lib/fog/libvirt/models/compute/volume.rb:41 calls create_volume with the wrong number of arguments
  #Broken before Fog 8d95d5bff223a199d33e297ea21884d8598f6921 because default pool name being "default-pool" and not "default" (with test:///default) triggers an internal bug
  def test_should_create_vm(name = "new_test")
    setup_user "create"
    assert_difference('@compute_resource.vms.count', +1) do
      attrs = {:name => name, :memory => 128*1024*1024, :domain_type => "test", :arch => "i686"}
      post :create, {:vm => attrs, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end
    assert_redirected_to compute_resource_vms_path
  end

  test "should not destroy vm when not permitted" do
    setup_user "view"
    assert_difference('@compute_resource.vms.count', 0) do
      delete :destroy, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    end

    assert_response 403
  end

  test "should not destroy vm when restricted" do
    setup_user "destroy"
    assert_difference('@your_compute_resource.vms.count', 0) do
      delete :destroy, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param}, set_session_user
    end

    assert_response 403
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

    assert_response 403
  end

  test "should not power vm when restricted" do
    setup_user "power"
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @your_compute_resource.to_param}, set_session_user

    assert_response 403
  end

  test "should power vm" do
    setup_user "power"

    get_test_vm
    assert @test_vm.ready?
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_redirected_to compute_resource_vms_path(:compute_resource_id => @compute_resource.to_param)
    get_test_vm
    assert !@test_vm.ready?

    # Swith it back on for next tests
    get :power, {:format => "json", :id => @test_vm.uuid, :compute_resource_id => @compute_resource.to_param}, set_session_user
    assert_redirected_to compute_resource_vms_path(:compute_resource_id => @compute_resource.to_param)
    get_test_vm
    assert @test_vm.ready?
  end

  def get_test_vm
    @compute_resource.vms.index {|vm| vm.name == "test" and @test_vm = vm}
  end

  def set_session_user
    User.current = users(:admin) unless User.current
    SETTINGS[:login] ? {:user => User.current.id, :expires_at => 5.minutes.from_now} : {}
  end

  def setup_user operation
    @one = users(:one)
    @request.session[:user] = @one.id
    as_admin do
      @one.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
      role = Role.find_or_create_by_name :name => "#{operation}_compute_resources_vms"
      role.permissions = ["#{operation}_compute_resources_vms".to_sym]
      role.save!
      @one.roles << [role]
      @one.compute_resources = [@compute_resource]
      @one.save!
    end
    User.current = @one
  end
end
