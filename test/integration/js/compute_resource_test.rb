require 'test_helper'

class ComputeResourceTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "create new libvirt compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "LibvirtServer"
    select "Libvirt", :from => "compute_resource_provider"
    fill_in "compute_resource_url", :with => "qemu://host.example.com/system"
    click_button "Submit"
    page.has_selector?('h1', :text => "LibvirtServer")
  end

  test "create new ovirt compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "OvirtServer"
    select "Ovirt", :from => "compute_resource_provider"
    fill_in "compute_resource_url", :with => "https://ovirt.example.com:8443/api"
    fill_in "compute_resource_user", :with => "admin@internal"  #User
    fill_in "compute_resource_password", :with => "secret"  #Pass
    click_link "Load Datacenters"
    select "Datacenter1", :from => "compute_resource_uuid"
    click_button "Submit"
    page.has_selector?('h1', :text => "OvirtServer")
  end

  test "create new ec2 compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "EC2Server"
    select "EC2", :from => "compute_resource_provider"
    fill_in "compute_resource_user", :with => "admin"  #Access Key
    fill_in "compute_resource_password", :with => "secret"  #Secrety Key
    click_link "Load Regions"
    select "eu-west-1", :from => "compute_resource_region"
    click_button "Submit"
    page.has_selector?('h1', :text => "EC2Server")
  end

  test "create new vmware compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "VmwareServer"
    select "Vmware", :from => "compute_resource_provider"
    fill_in "compute_resource_server", :with => "vmware.server.com"
    fill_in "compute_resource_user", :with => "admin"  #Access Key
    fill_in "compute_resource_password", :with => "secret"  #Secrety Key
    click_link "Load Datacenters"
    select "Solutions", :from => "compute_resource_uuid"
    click_button "Submit"
    page.has_selector?('h1', :text => "VmwareServer")
  end

  test "create new openstack compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "OpenStackServer"
    select "Openstack", :from => "compute_resource_provider"
    fill_in "compute_resource_url", :with => "https://openstack.example.com"
    fill_in "compute_resource_user", :with => "admin"  #Access Key
    fill_in "compute_resource_password", :with => "secret"  #Secrety Key
    click_link "Load Tenants"
    select "admin", :from => "compute_resource_tenant"
    click_button "Submit"
    page.has_selector?('h1', :text => "OpenStackServer")
  end

  test "create new rackspace compute resource" do
    assert_new_button(compute_resources_path,"New Compute Resource",new_compute_resource_path)
    fill_in "compute_resource_name", :with => "RackspaceServer"
    select "Rackspace", :from => "compute_resource_provider"
    fill_in "compute_resource_url", :with => "https://identity.api.rackspacecloud.com"
    fill_in "compute_resource_user", :with => "admin"  #Access Key
    fill_in "compute_resource_password", :with => "secret"  #Secrety Key
    select "DFW", :from => "compute_resource_region"
    click_button "Submit"
    page.has_selector?('h1', :text => "RackspaceServer")
  end

  test "sucessfully delete row" do
    assert_delete_row(compute_resources_path, "mycompute", "Delete", true)
  end

  test "cannot delete row if used" do
    assert_cannot_delete_row(compute_resources_path, "bigcompute", "Delete", true)
  end

  # PENDING
  # create, delete
  # Power On
  # New Image
  # New vms
  # Tab - Virtual Machines
  # Tab - Images


end
