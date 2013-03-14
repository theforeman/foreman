require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    disable_orchestration
    fix_mismatches
  end

  # context - BareMetal NO orgs/locations
  test "create new baremetal host without org or loc" do
    SETTINGS[:organizations_enabled] = false
    SETTINGS[:locations_enabled] = false
    click_new_and_enter_name
    select_compute_resource("Bare Metal")
    create_baremetal_host_steps
  end

  # context - BareMetal WITH orgs/locations
  test "create new baremetal host with org or loc" do
    SETTINGS[:organizations_enabled] = true
    SETTINGS[:locations_enabled] = true
    click_new_and_enter_name
    select_location_and_organization
    select_compute_resource("Bare Metal")
    create_baremetal_host_steps
  end

  # context - ec2 WITH orgs/locations
  test "create new ec2 host with org or loc" do
    SETTINGS[:organizations_enabled] = true
    SETTINGS[:locations_enabled] = true
    click_new_and_enter_name
    select_location_and_organization
    select_compute_resource("amazon123 (eu-west-1-EC2)")
    create_ec2_host_steps
  end

  # context - ec2 WITH orgs/locations
  test "create new ec2 host without org or loc" do
    SETTINGS[:organizations_enabled] = false
    SETTINGS[:locations_enabled] = false
    click_new_and_enter_name
    select_compute_resource("amazon123 (eu-west-1-EC2)")
    create_ec2_host_steps
  end

  def click_new_and_enter_name
    assert_new_button(hosts_path,"New Host",new_host_path)
    fill_in "host_name", :with => "foreman.test.com"
  end

  def select_location_and_organization
    select "Location 1", :from => "host_location_id"
    select "Organization 1", :from => "host_organization_id"
  end

  def select_compute_resource(name)
    select name, :from => "host_compute_resource_id"
  end

  def create_baremetal_host_steps
    select "Common", :from => "host_hostgroup_id"
    select "production", :from => "host_environment_id"
    click_link(:href => "#network")
    fill_in "host_mac", :with => "aa:cd:aa:bc:de:ca"
    select "mydomain.net", :from => "host_domain_id"
    fill_in "host_ip", :with => "10.7.51.73"
    click_link(:href => "#os")
    select "x86_64", :from => "host_architecture_id"
    select "centos 5.3", :from => "host_operatingsystem_id"
    click_button "Submit"
    assert page.has_selector?('h1', :text => "foreman.test.com"), "foreman.test.com was expected in the <h1> tag, but was not found"
  end

  def create_ec2_host_steps
    select "Common", :from => "host_hostgroup_id"
    select "production", :from => "host_environment_id"
    click_link(:href => "#network")
    select "mydomain.net", :from => "host_domain_id"
    click_link(:href => "#os")
    select "x86_64", :from => "host_architecture_id"
    select "centos 5.3", :from => "host_operatingsystem_id"
    click_button "Submit"
    assert page.has_selector?('h1', :text => "foreman.test.com"), "foreman.test.com was expected in the <h1> tag, but was not found"
  end


  # PENDING
  # edit, clone, delete

end
