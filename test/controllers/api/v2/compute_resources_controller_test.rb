require 'test_helper'

class Api::V2::ComputeResourcesControllerTest < ActionController::TestCase
  def setup
    Fog.mock!
  end

  def teardown
    Fog.unmock!
  end

  valid_attrs = { :name => 'special_compute', :provider => 'EC2', :region => 'eu-west-1', :user => 'user@example.com', :password => 'secret' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    assert !compute_resources.empty?
  end

  test "should show compute_resource" do
    get :show, params: { :id => compute_resources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid compute resource" do
    post :create, params: { :compute_resource => valid_attrs }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update compute resource" do
    put :update, params: { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_equal "new_description",
      ComputeResource.unscoped.find_by_name('mycompute').description
    assert_response :success
  end

  test "should destroy compute resource" do
    assert_difference('ComputeResource.unscoped.count', -1) do
      delete :destroy, params: { :id => compute_resources(:yourcompute).id }
    end
    assert_response :success
  end

  test "should get index of owned" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :index
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    ids               = compute_resources['results'].map { |hash| hash['id'] }
    assert_includes ids, compute_resources(:mycompute).id
    refute_includes ids, compute_resources(:yourcompute).id
  end

  test "should allow access to a compute resource for owner" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :show, params: { :id => compute_resources(:mycompute).to_param }
    assert_response :success
  end

  test "should update compute resource for owner" do
    setup_user 'edit', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    put :update, params: { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_equal "new_description",
      ComputeResource.unscoped.find_by_name('mycompute').description
    assert_response :success
  end

  test "should destroy compute resource for owner" do
    assert_difference('ComputeResource.unscoped.count', -1) do
      setup_user 'destroy', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
      delete :destroy, params: { :id => compute_resources(:mycompute).id }
    end
    assert_response :success
  end

  test "should not allow access to a compute resource out of users compute resources scope" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :show, params: { :id => compute_resources(:one).to_param }
    assert_response :not_found
  end

  test "should not update compute resource for restricted" do
    setup_user 'edit', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    put :update, params: { :id => compute_resources(:yourcompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_response :not_found
  end

  test "should not destroy compute resource for restricted" do
    setup_user 'destroy', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    delete :destroy, params: { :id => compute_resources(:yourcompute).id }
    assert_response :not_found
  end

  test "should get available images" do
    img = Object.new
    img.stubs(:name).returns('some_image')
    img.stubs(:id).returns('123')

    Foreman::Model::EC2.any_instance.stubs(:available_images).returns([img])

    get :available_images, params: { :id => compute_resources(:ec2).to_param }
    assert_response :success
    available_images = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty available_images
  end

  test "should get available virtual machines" do
    vm = Object.new
    vm.stubs(:name).returns('some_vm')
    vm.stubs(:id).returns('123456')

    Foreman::Model::EC2.any_instance.stubs(:available_virtual_machines).returns([vm])

    get :available_virtual_machines, params: { :id => compute_resources(:ovirt).to_param }
    assert_response :success
    available_virtual_machines = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty available_virtual_machines
  end

  test "should get available networks" do
    network = Object.new
    network.stubs(:name).returns('test_network')
    network.stubs(:id).returns('my11-test35-uuid99')

    Foreman::Model::Ovirt.any_instance.stubs(:available_networks).returns([network])

    get :available_networks, params: { :id => compute_resources(:ovirt).to_param, :cluster_id => '123-456-789' }
    assert_response :success
    available_networks = ActiveSupport::JSON.decode(@response.body)
    assert !available_networks.empty?
  end

  test "should get available clusters" do
    cluster = Object.new
    cluster.stubs(:name).returns('test_cluster')
    cluster.stubs(:id).returns('my11-test35-uuid99')

    Foreman::Model::Ovirt.any_instance.stubs(:available_clusters).returns([cluster])

    get :available_clusters, params: { :id => compute_resources(:ovirt).to_param }
    assert_response :success
    available_clusters = ActiveSupport::JSON.decode(@response.body)
    assert !available_clusters.empty?
  end

  test "should get available storage domains" do
    storage_domain = Object.new
    storage_domain.stubs(:name).returns('test_cluster')
    storage_domain.stubs(:id).returns('my11-test35-uuid99')

    Foreman::Model::Ovirt.any_instance.stubs(:available_storage_domains).returns([storage_domain])

    get :available_storage_domains, params: { :id => compute_resources(:ovirt).to_param }
    assert_response :success
    available_storage_domains = ActiveSupport::JSON.decode(@response.body)
    assert !available_storage_domains.empty?
  end

  test "should create with datacenter name" do
    Foreman::Model::Ovirt.any_instance.stubs(:datacenters).returns([["test", Foreman.uuid]])
    Foreman::Model::Ovirt.any_instance.stubs(:test_connection).returns(true)

    attrs = { :name => 'Ovirt-create-test', :url => 'https://myovirt/api', :provider => 'ovirt', :datacenter => 'test', :user => 'user@example.com', :password => 'secret' }
    post :create, params: { :compute_resource => attrs }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert Foreman.is_uuid?(show_response["datacenter"])
  end

  test "should create with datacenter uuid" do
    datacenter_uuid = Foreman.uuid
    Foreman::Model::Ovirt.any_instance.stubs(:datacenters).returns([["test", datacenter_uuid]])

    attrs = { :name => 'Ovirt-create-test', :url => 'https://myovirt/api', :provider => 'ovirt', :datacenter => datacenter_uuid, :user => 'user@example.com', :password => 'secret' }
    post :create, params: { :compute_resource => attrs }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert Foreman.is_uuid?(show_response["datacenter"])
  end

  test "should update with datacenter name" do
    compute_resource = compute_resources(:ovirt)
    Foreman::Model::Ovirt.any_instance.stubs(:datacenters).returns([["test", Foreman.uuid]])
    Foreman::Model::Ovirt.any_instance.stubs(:test_connection).returns(true)

    attrs = { :datacenter => 'test' }
    post :update, params: { :id => compute_resource.id, :compute_resource => attrs }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert Foreman.is_uuid?(show_response["datacenter"])
  end

  context 'cache refreshing' do
    test 'should refresh cache if supported' do
      put :refresh_cache, params: { :id => compute_resources(:vmware).to_param }
      assert_response :success
    end

    test 'should fail if unsupported' do
      put :refresh_cache, params: { :id => compute_resources(:ovirt).to_param }
      assert_response :error
    end
  end

  context 'ec2' do
    setup do
      @ec2_object = Object.new
      @ec2_object.stubs(:name).returns('test_ec2_object')
    end

    teardown do
      assert_response :success
      available_objects = ActiveSupport::JSON.decode(@response.body)
      assert_not_empty available_objects
    end

    test "should get available flavors" do
      @ec2_object.stubs(:id).returns('123')
      Foreman::Model::EC2.any_instance.stubs(:available_flavors).returns([@ec2_object])
      get :available_flavors, params: { :id => compute_resources(:ec2).to_param }
    end

    test "should get available security groups" do
      @ec2_object.stubs(:group_id).returns('123')
      Foreman::Model::EC2.any_instance.stubs(:available_security_groups).returns([@ec2_object])
      get :available_security_groups, params: { :id => compute_resources(:ec2).to_param }
    end

    test "should get available zones" do
      Foreman::Model::EC2.any_instance.stubs(:available_zones).returns(['test_ec2_object'])
      get :available_zones, params: { :id => compute_resources(:ec2).to_param }
    end
  end

  context 'vmware' do
    setup do
      @vmware_object = Object.new
      @vmware_object.stubs(:name).returns('test_vmware_object')
      @vmware_object.stubs(:id).returns('my11-test35-uuid99')
    end

    teardown do
      assert_response :success
      available_objects = ActiveSupport::JSON.decode(@response.body)
      assert_not_empty available_objects
    end

    test "should get available vmware networks" do
      Foreman::Model::Vmware.any_instance.stubs(:available_networks).returns([@vmware_object])
      get :available_networks, params: { :id => compute_resources(:vmware).to_param, :cluster_id => '123-456-789' }
    end

    test "should get available vmware clusters" do
      Foreman::Model::Vmware.any_instance.stubs(:available_clusters).returns([@vmware_object])
      get :available_clusters, params: { :id => compute_resources(:vmware).to_param }
    end

    test "should get available vmware storage domains" do
      Foreman::Model::Vmware.any_instance.stubs(:available_storage_domains).returns([@vmware_object])
      get :available_storage_domains, params: { :id => compute_resources(:vmware).to_param }
    end

    test "should get available vmware storage pods" do
      Foreman::Model::Vmware.any_instance.stubs(:available_storage_pods).returns([@vmware_object])
      get :available_storage_pods, params: { :id => compute_resources(:vmware).to_param }
    end

    test "should get available vmware resource pools" do
      Foreman::Model::Vmware.any_instance.stubs(:available_resource_pools).returns([@vmware_object])
      get :available_resource_pools, params: { :id => compute_resources(:vmware).to_param, :cluster_id => '123-456-789' }
    end

    test "should get available vmware folders" do
      Foreman::Model::Vmware.any_instance.stubs(:available_folders).returns([@vmware_object])
      get :available_folders, params: { :id => compute_resources(:vmware).to_param, :cluster_id => '123-456-789' }
    end
  end

  test "should get specific vmware storage domain - the deprecated way" do
    storage_domain = OpenStruct.new(id: 'my11-test35-uuid99', name: 'test_vmware_datastore')

    Foreman::Model::Vmware.any_instance.expects(:storage_domain).with('test_vmware_datastore').returns(storage_domain)

    Foreman::Deprecation.expects(:api_deprecation_warning)

    get :available_storage_domains, params: { :id => compute_resources(:vmware).to_param, :storage_domain => 'test_vmware_datastore' }
    assert_response :success
    available_storage_domains = ActiveSupport::JSON.decode(@response.body)
    assert_equal storage_domain.id, available_storage_domains['results'].first.try(:[], 'id')
  end

  test "should get specific vmware storage domain" do
    storage_domain = OpenStruct.new(id: 'my11-test35-uuid99', name: 'test_vmware_datastore')

    Foreman::Model::Vmware.any_instance.expects(:storage_domain).with('test_vmware_datastore').returns(storage_domain)

    get :storage_domain, params: { :id => compute_resources(:vmware).to_param, :storage_domain_id => 'test_vmware_datastore' }
    assert_response :success
    storage_domain_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal storage_domain.id, storage_domain_response.try(:[], 'id')
  end

  test "should get specific vmware storage pod - the deprecated way" do
    storage_pod = OpenStruct.new(id: 'group-p123456', name: 'test_vmware_pod')

    Foreman::Model::Vmware.any_instance.expects(:storage_pod).with('test_vmware_pod').returns(storage_pod)

    Foreman::Deprecation.expects(:api_deprecation_warning)

    get :available_storage_pods, params: { :id => compute_resources(:vmware).to_param, :storage_pod => 'test_vmware_pod' }
    assert_response :success
    available_storage_pods = ActiveSupport::JSON.decode(@response.body)
    assert_equal storage_pod.id, available_storage_pods['results'].first.try(:[], 'id')
  end

  test "should get specific vmware storage pod" do
    storage_pod = OpenStruct.new(id: 'group-p123456', name: 'test_vmware_pod')

    Foreman::Model::Vmware.any_instance.expects(:storage_pod).with('test_vmware_pod').returns(storage_pod)

    get :storage_pod, params: { :id => compute_resources(:vmware).to_param, :storage_pod_id => 'test_vmware_pod' }
    assert_response :success
    storage_pod_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal storage_pod.id, storage_pod_response.try(:[], 'id')
  end

  test "should associate hosts that match" do
    host_cr = FactoryBot.create(:host, :on_compute_resource)
    host_bm = FactoryBot.create(:host)

    uuid = Foreman.uuid
    vm2 = mock('vm2')
    vm2.expects(:identity).at_least_once.returns(uuid)
    vms = [mock('vm1', :identity => host_cr.uuid), vm2]
    ComputeResource.any_instance.expects(:vms).returns(vms)
    Foreman::Model::EC2.any_instance.expects(:associated_host).returns(host_bm)
    put :associate, params: { :id => host_cr.compute_resource.to_param }
    assert_response :success

    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_equal [host_bm.id], hosts['results'].map { |h| h['id'] }
    assert_equal uuid, host_bm.reload.uuid
    assert_equal host_cr.compute_resource.id, host_bm.compute_resource_id
    assert host_bm.compute?
  end

  test "should associate hosts that match to a specific vm" do
    host_cr = FactoryBot.create(:host, :on_compute_resource)
    host_bm = FactoryBot.create(:host)

    uuid = Foreman.uuid
    vm2 = mock('vm2')
    vm2.expects(:identity).at_least_once.returns(uuid)
    Foreman::Model::EC2.any_instance.expects(:associated_host).returns(host_bm)
    Foreman::Model::EC2.any_instance.expects(:find_vm_by_uuid).returns(vm2)
    put :associate, params: { :id => host_cr.compute_resource.id, :vm_id => uuid }
    assert_response :success

    hosts = ActiveSupport::JSON.decode(@response.body)
    assert_equal [host_bm.id], hosts['results'].map { |h| h['id'] }
    assert_equal uuid, host_bm.reload.uuid
    assert_equal host_cr.compute_resource.id, host_bm.compute_resource_id
    assert host_bm.compute?
  end

  test "should update boolean attribute set_console_password for Libvirt compute resource" do
    cr = compute_resources(:one)
    put :update, params: { :id => cr.id, :compute_resource => { :set_console_password => true } }
    assert_response :success
    cr.reload
    assert_equal 1, cr.attrs[:setpw]
  end

  test "should update boolean attribute set_console_password for VMware compute resource" do
    cr = compute_resources(:vmware)
    put :update, params: { :id => cr.id, :compute_resource => { :set_console_password => true } }
    assert_response :success
    cr.reload
    assert_equal 1, cr.attrs[:setpw]
  end

  test "should update compute attribute datacenter for VMware compute resource" do
    cr = FactoryBot.create(:vmware_cr)
    FactoryBot.create(:compute_attribute, compute_resource: cr)
    attrs = { :provider => 'Vmware', :datacenter => 'Solutions' }
    put :update, params: { :id => cr.id, :compute_resource => attrs }
    assert_response :success
    cr.reload
    assert_equal '/Datacenters/Solutions/vm', cr.compute_attributes.first.vm_attrs['path']
  end

  test "should not update set_console_password to true for non-VMware or non-Libvirt compute resource" do
    cr = compute_resources(:openstack)
    put :update, params: { :id => cr.id, :compute_resource => { :set_console_password => true } }
    assert_response :success
    cr.reload
    assert_nil cr.attrs[:setpw]
  end

  test "should not update display_type for non-Libvirt compute resource" do
    cr = compute_resources(:openstack)
    put :update, params: { :id => cr.id, :compute_resource => { :display_type => 'SPICE' } }
    assert_response :success
    cr.reload
    assert_nil cr.attrs[:display]
  end

  test "should update libvirt compute resource with valid name" do
    name = RFauxFactory.gen_alpha
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:name => name } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['name'], name, "Can't update libvirt compute resource with valid name #{name}"
  end

  test "should update libvirt compute resource with vnc display type" do
    display_type = "vnc"
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:display_type => display_type } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['display_type'], display_type, "Can't update libvirt compute resource with valid display type #{display_type}"
  end

  test "should update libvirt compute resource with spice display type" do
    display_type = "spice"
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:display_type => display_type } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['display_type'], display_type, "Can't update libvirt compute resource with valid display type #{display_type}"
  end

  test "should update libvirt compute resource with valid url" do
    new_url = "qemu+tcp://dummy.theforeman.org:16509/system"
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:url => new_url } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['url'], new_url, "Can't update libvirt compute resource with valid url #{new_url}"
  end

  test "should update libvirt compute resource with loc" do
    new_location = Location.second
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:location_ids => [new_location.id] } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['locations'].length, 1
    assert_equal response['locations'][0]['id'], new_location.id, "Can't update libvirt compute resource with loc #{new_location}"
  end

  test "should update libvirt compute resource with org" do
    new_organization = Organization.second
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:organization_ids => [new_organization.id] } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['organizations'].length, 1
    assert_equal response['organizations'][0]['id'], new_organization.id, "Can't update libvirt compute resource with org #{new_organization}"
  end

  test "should update libvirt compute resource with orgs" do
    new_organizations = [Organization.first, Organization.second, Organization.third]
    put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:organization_ids => new_organizations.map { |org| org.id } } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['organizations'].map { |org| org['name'] }.sort, new_organizations.map { |org| org.name }, "Can't update libvirt compute resource with orgs #{new_organizations}"
  end

  test "should not create with same name" do
    post :create, params: { :compute_resource => { :name => compute_resources(:mycompute).name, :provider => 'libvirt' } }
    assert_response :unprocessable_entity, "Can create libvirt compute resource with the name of already existing resource"
  end

  test "should not update with unknown provider" do
    post :create, params: { :compute_resource => { :name => compute_resources(:mycompute).name, :provider => 'unknown' } }
    assert_response :unprocessable_entity, "unknown provider"
  end

  test "should not update with already taken name" do
    compute_resource = FactoryBot.create(:libvirt_cr)
    put :update, params: { :id => compute_resource.id, :compute_resource => { :name => compute_resources(:mycompute).name } }
    assert_response :unprocessable_entity, "Can update libvirt compute resource with the name of already existing resource"
  end

  test "should not update with empty name" do
    url = ""
    compute_resource = FactoryBot.create(:libvirt_cr)
    put :update, params: { :id => compute_resource.id, :compute_resource => { :url => url } }
    assert_response :unprocessable_entity, "Can create libvirt compute resource with empty name"
  end

  test "should not update with invalid name" do
    url = RFauxFactory.gen_alpha
    compute_resource = FactoryBot.create(:libvirt_cr)
    put :update, params: { :id => compute_resource.id, :compute_resource => { :url => url } }
    assert_response :unprocessable_entity, "Can create libvirt compute resource with invalid name"
  end

  context 'libvirt' do
    setup do
      @organization = Organization.first
      @location = Location.first
      @valid_libvirt_attrs = { :name => 'libvirt_compute', :provider => 'libvirt', :url => 'qemu+ssh://root@libvirt.example.com/system' }
      @valid_libvirt_with_org_loc = { :name => 'libvirt_compute', :provider => 'libvirt', :organization_ids => [@organization.id], :location_ids => [@location.id], :url => 'qemu+ssh://root@libvirt.example.com/system' }
    end

    test "should create libvirt compute resource with valid name" do
      name = @valid_libvirt_with_org_loc[:name]
      post :create, params: { :compute_resource => @valid_libvirt_with_org_loc }
      assert_response :created
      assert_equal JSON.parse(@response.body)['name'], name, "Can't create libvirt compute resource with valid name #{name}"
    end

    test "should create libvirt compute resource with valid description" do
      description = RFauxFactory.gen_alpha
      libvirt_with_description = @valid_libvirt_with_org_loc.clone.update(:description => description)
      post :create, params: { :compute_resource => libvirt_with_description }
      assert_response :created
      assert_equal JSON.parse(@response.body)['description'], description, "Can't create libvirt compute resource with valid description #{description}"
    end

    test "should create libvirt compute resource with spice display_type" do
      display_type = 'spice'
      libvirt_spice_display_type = @valid_libvirt_with_org_loc.clone.update(:display_type => display_type)
      post :create, params: { :compute_resource => libvirt_spice_display_type }
      assert_response :created
      assert_equal JSON.parse(@response.body)['display_type'], display_type, "Can't create libvirt compute resource with valid display_type #{display_type}"
    end

    test "should create libvirt compute resource with spice display_type" do
      display_type = 'vnc'
      libvirt_vnc_display_type = @valid_libvirt_with_org_loc.clone.update(:display_type => display_type)
      post :create, params: { :compute_resource => libvirt_vnc_display_type }
      assert_response :created
      assert_equal JSON.parse(@response.body)['display_type'], display_type, "Can't create libvirt compute resource with valid display_type #{display_type}"
    end

    test "should create libvirt compute resource with locs" do
      locs = Array.new(3) { FactoryBot.create(:location, :organization_ids => [@organization.id]) }
      libvirt_with_locs = @valid_libvirt_with_org_loc.clone.update(:location_ids => locs.map { |loc| loc.id })
      post :create, params: { :compute_resource => libvirt_with_locs }
      assert_response :created
      assert_equal JSON.parse(@response.body)['locations'].map { |loc| loc['name'] }, locs.map { |loc| loc.name }, "Can't create libvirt compute resource with locs #{locs}"
    end

    test "should create libvirt compute resource with orgs" do
      orgs = [Organization.first, Organization.second, Organization.third]
      libvirt_with_orgs = @valid_libvirt_attrs.clone.update(:organization_ids => orgs.map { |org| org.id })
      post :create, params: { :compute_resource => libvirt_with_orgs }
      assert_response :created
      assert_equal JSON.parse(@response.body)['organizations'].map { |org| org['name'] }, orgs.map { |org| org.name }, "Can't create libvirt compute resource with orgs #{orgs}"
    end

    test "should update libvirt compute resource with locs" do
      new_locations = Array.new(3) { FactoryBot.create(:location, :organization_ids => [@organization.id]) }
      put :update, params: { :id => compute_resources(:mycompute).id, :compute_resource => {:location_ids => new_locations.map { |loc| loc.id } } }
      assert_response :success
      assert_equal JSON.parse(@response.body)['locations'].map { |loc| loc['name'] }, new_locations.map { |loc| loc.name }, "Can't update libvirt compute resource with locs #{new_locations}"
    end

    test "should not create libvirt compute resource with invalid name" do
      name = ""
      libvirt_with_invalid_name = @valid_libvirt_with_org_loc.clone.update(:name => name)
      post :create, params: { :compute_resource => libvirt_with_invalid_name }
      assert_response :unprocessable_entity, "Can create libvirt compute resource with invalid name #{name}"
    end

    test "should not create with empty url" do
      url = ""
      libvirt_with_invalid_url = @valid_libvirt_with_org_loc.clone.update(:url => url)
      post :create, params: { :compute_resource => libvirt_with_invalid_url }
      assert_response :unprocessable_entity, "Can create libvirt compute resource with empty url"
    end

    test "should not create with invalid url" do
      url = RFauxFactory.gen_alpha
      libvirt_with_invalid_url = @valid_libvirt_with_org_loc.clone.update(:url => url)
      post :create, params: { :compute_resource => libvirt_with_invalid_url }
      assert_response :unprocessable_entity, "Can create libvirt compute resource with invalid name"
    end
  end
end
