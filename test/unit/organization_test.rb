require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test 'it should not save with an empty name' do
    organization = Organization.new
    assert !organization.save
  end

  test 'it should not save with a blank name' do
    organization = Organization.new
    organization.name = " "
    assert !organization.save
  end

  test 'it should not save another organization with the same name' do
    organization = Organization.new
    organization.name = "organization1"
    assert organization.save

    second_organization = Organization.new
    second_organization.name = "organization1"
    assert !second_organization.save
  end

  test 'it should show the name for to_s' do
    organization = Organization.new :name => "organization1"
    assert organization.to_s == "Organization1"
  end

    test 'organization is invalid without any taxable_taxonomies' do
    # no taxable_taxonomies in fixtures
    # no ignore_types in fixtures
    organization = taxonomies(:organization1)
    assert !organization.valid?
  end

  test 'organization is valid if ignore all types' do
    organization = taxonomies(:organization1)
    organization.location_ids = [taxonomies(:location1).id]
    organization.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    assert organization.valid?
  end

  test 'organization is valid after fixture mismatches' do
    organization = taxonomies(:organization1)
    Taxonomy.all_import_missing_ids
    assert organization.valid?
  end

  test 'it should return array of used ids by hosts' do
    organization = taxonomies(:organization1)
    # run used_ids method
    used_ids = organization.used_ids
    # get results from Host object
    environment_ids = Host.where(:organization_id => organization.id).pluck(:environment_id).compact.uniq
    hostgroup_ids = Host.where(:organization_id => organization.id).pluck(:hostgroup_id).compact.uniq
    subnet_ids = Host.where(:organization_id => organization.id).pluck(:subnet_id).compact.uniq
    domain_ids = Host.where(:organization_id => organization.id).pluck(:domain_id).compact.uniq
    medium_ids = Host.where(:organization_id => organization.id).pluck(:medium_id).compact.uniq
    compute_resource_ids = Host.where(:organization_id => organization.id).pluck(:compute_resource_id).compact.uniq
    user_ids = Host.where(:organization_id => organization.id).where(:owner_type => 'User').pluck(:owner_id).compact.uniq
    smart_proxy_ids = Host.where(:organization_id => organization.id).map {|host| host.smart_proxies.map(&:id)}.flatten.compact.uniq
    config_template_ids = Host.where("organization_id = #{organization.id} and operatingsystem_id > 0").map {|host| host.configTemplate.try(:id)}.compact.uniq
    # match to above retrieved data
    assert_equal used_ids[:environment_ids], environment_ids
    assert_equal used_ids[:hostgroup_ids], hostgroup_ids
    assert_equal used_ids[:subnet_ids], subnet_ids
    assert_equal used_ids[:domain_ids], domain_ids
    assert_equal used_ids[:medium_ids], medium_ids
    assert_equal used_ids[:compute_resource_ids], compute_resource_ids
    assert_equal used_ids[:user_ids].sort, user_ids.sort
    assert_equal used_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
    assert_equal used_ids[:config_template_ids], config_template_ids
    # match to raw fixtures data
    assert_equal used_ids[:environment_ids].sort, Array(environments(:production).id).sort
    assert_equal used_ids[:hostgroup_ids].sort, Array.new
    assert_equal used_ids[:subnet_ids].sort, Array(subnets(:one).id).sort
    assert_equal used_ids[:domain_ids].sort, Array(domains(:mydomain).id).sort
    assert_equal used_ids[:medium_ids].sort, Array.new
    assert_equal used_ids[:compute_resource_ids].sort, Array(compute_resources(:one).id).sort
    assert_equal used_ids[:user_ids], Array.new
    assert_equal used_ids[:smart_proxy_ids].sort, Array([smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:puppetmaster).id]).sort
    assert_equal used_ids[:config_template_ids].sort, Array(config_templates(:mystring2).id).sort
  end

  test 'it should return selected_ids array of selected values only (when types are not ignored)' do
    organization = taxonomies(:organization1)
    #fixtures for taxable_taxonomies don't work, on has_many :through polymorphic
    # so I created assocations here.
    organization.subnet_ids = Array(subnets(:one).id)
    organization.smart_proxy_ids = Array(smart_proxies(:puppetmaster).id)
    # run selected_ids method
    selected_ids = organization.selected_ids
    # get results from taxable_taxonomies
    environment_ids = organization.environment_ids
    hostgroup_ids = organization.hostgroup_ids
    subnet_ids = organization.subnet_ids
    domain_ids = organization.domain_ids
    medium_ids = organization.medium_ids
    user_ids = organization.user_ids
    smart_proxy_ids = organization.smart_proxy_ids
    config_template_ids = organization.config_template_ids
    compute_resource_ids = organization.compute_resource_ids
    # check if they match
    assert_equal selected_ids[:environment_ids], environment_ids
    assert_equal selected_ids[:hostgroup_ids], hostgroup_ids
    assert_equal selected_ids[:subnet_ids], subnet_ids
    assert_equal selected_ids[:domain_ids], domain_ids
    assert_equal selected_ids[:medium_ids], medium_ids
    assert_equal selected_ids[:user_ids], user_ids
    assert_equal selected_ids[:smart_proxy_ids], smart_proxy_ids
    assert_equal selected_ids[:config_template_ids], config_template_ids
    assert_equal selected_ids[:compute_resource_ids], compute_resource_ids
    # match to manually generated taxable_taxonomies
    assert_equal selected_ids[:environment_ids], Array.new
    assert_equal selected_ids[:hostgroup_ids], Array.new
    assert_equal selected_ids[:subnet_ids].sort, Array(subnets(:one).id)
    assert_equal selected_ids[:domain_ids], Array.new
    assert_equal selected_ids[:medium_ids], Array.new
    assert_equal selected_ids[:user_ids], Array.new
    assert_equal selected_ids[:smart_proxy_ids].sort, Array(smart_proxies(:puppetmaster).id)
    assert_equal selected_ids[:config_template_ids], Array.new
    assert_equal selected_ids[:compute_resource_ids], Array.new
  end

  test 'it should return selected_ids array of ALL values (when types are ignored)' do
    organization = taxonomies(:organization1)
    # ignore all types
    organization.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    # run selected_ids method
    selected_ids = organization.selected_ids
    # should return empty [] for array
    assert_equal selected_ids[:environment_ids], Array.new
    assert_equal selected_ids[:hostgroup_ids], Array.new
    assert_equal selected_ids[:subnet_ids], Array.new
    assert_equal selected_ids[:domain_ids], Array.new
    assert_equal selected_ids[:medium_ids], Array.new
    assert_equal selected_ids[:user_ids], Array.new
    assert_equal selected_ids[:smart_proxy_ids], Array.new
    assert_equal selected_ids[:config_template_ids], Array.new
    assert_equal selected_ids[:compute_resource_ids], Array.new
  end

  #Clone
  test "it should clone organization with all associations" do
    organization = taxonomies(:organization1)
    organization_dup = organization.dup
    organization_dup.name = "organization_dup_name"
    assert organization_dup.save!
    assert_equal, organization_dup.environment_ids = organization.environment_ids
    assert_equal, organization_dup.hostgroup_ids = organization.hostgroup_ids
    assert_equal, organization_dup.subnet_ids = organization.subnet_ids
    assert_equal, organization_dup.domain_ids = organization.domain_ids
    assert_equal, organization_dup.medium_ids = organization.medium_ids
    assert_equal, organization_dup.user_ids = organization.user_ids
    assert_equal, organization_dup.smart_proxy_ids = organization.smart_proxy_ids
    assert_equal, organization_dup.config_template_ids = organization.config_template_ids
    assert_equal, organization_dup.compute_resource_ids = organization.compute_resource_ids
    assert_equal, organization_dup.location_ids = organization.location_ids
  end


end
