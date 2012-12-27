require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test 'it should not save without an empty name' do
    location = Location.new
    assert !location.save
  end

  test 'it should not save with a blank name' do
    location = Location.new
    location.name = "      "
    assert !location.save
  end

  test 'it should not save another location with the same name' do
    location = Location.new
    location.name = "location1"
    assert location.save

    second_location = Location.new
    second_location.name = "location1"
    assert !second_location.save
  end

  test 'it should show the name for to_s' do
    location = Location.new :name => "location name"
    assert location.to_s == "Location name"
  end

  test 'location is invalid without any taxable_taxonomies' do
    # no taxable_taxonomies in fixtures
    # no ignore_types in fixtures
    location = taxonomies(:location1)
    assert !location.valid?
  end

  test 'location is valid if ignore all types' do
    location = taxonomies(:location1)
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    assert location.valid?
  end

  test 'location is valid after fixture mismatches' do
    location = taxonomies(:location1)
    Taxonomy.all_import_missing_ids
    assert location.valid?
  end

  test 'it should return array of used ids by hosts' do
    location = taxonomies(:location1)
    # run used_ids method
    used_ids = location.used_ids
    # get results from Host object
    environment_ids = Host.where(:location_id => location.id).pluck(:environment_id).compact.uniq
    hostgroup_ids = Host.where(:location_id => location.id).pluck(:hostgroup_id).compact.uniq
    subnet_ids = Host.where(:location_id => location.id).pluck(:subnet_id).compact.uniq
    domain_ids = Host.where(:location_id => location.id).pluck(:domain_id).compact.uniq
    medium_ids = Host.where(:location_id => location.id).pluck(:medium_id).compact.uniq
    compute_resource_ids = Host.where(:location_id => location.id).pluck(:compute_resource_id).compact.uniq
    user_ids = Host.where(:location_id => location.id).where(:owner_type => 'User').pluck(:owner_id).compact.uniq
    smart_proxy_ids = Host.where(:location_id => location.id).map {|host| host.smart_proxies.map(&:id)}.flatten.compact.uniq
    config_template_ids = Host.where("location_id = #{location.id} and operatingsystem_id > 0").map {|host| host.configTemplate.try(:id)}.compact.uniq
    # match to above retrieved data
    assert_equal used_ids[:environment_ids], environment_ids
    assert_equal used_ids[:hostgroup_ids], hostgroup_ids
    assert_equal used_ids[:subnet_ids], subnet_ids
    assert_equal used_ids[:domain_ids], domain_ids
    assert_equal used_ids[:medium_ids], medium_ids
    assert_equal used_ids[:compute_resource_ids], compute_resource_ids
    assert_equal used_ids[:user_ids], user_ids
    assert_equal used_ids[:smart_proxy_ids], smart_proxy_ids
    assert_equal used_ids[:config_template_ids], config_template_ids
    # match to raw fixtures data
    assert_equal used_ids[:environment_ids].sort, Array(environments(:production).id).sort
    assert_equal used_ids[:hostgroup_ids].sort, Array.new
    assert_equal used_ids[:subnet_ids].sort, Array(subnets(:one).id).sort
    assert_equal used_ids[:domain_ids].sort, Array([domains(:yourdomain).id, domains(:mydomain).id]).sort
    assert_equal used_ids[:medium_ids].sort, Array(media(:one).id).sort
    assert_equal used_ids[:compute_resource_ids].sort, Array(compute_resources(:one).id).sort
    assert_equal used_ids[:user_ids], Array.new
    assert_equal used_ids[:smart_proxy_ids].sort, Array([smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:puppetmaster).id]).sort
    assert_equal used_ids[:config_template_ids].sort, Array(config_templates(:mystring2).id).sort
  end

  test 'it should return selected_ids array of selected values only (when types are not ignored)' do
    location = taxonomies(:location1)
    #fixtures for taxable_taxonomies don't work, on has_many :through polymorphic
    # so I created assocations here.
    location.subnet_ids = Array(subnets(:one).id)
    location.smart_proxy_ids = Array(smart_proxies(:puppetmaster).id)
    # run selected_ids method
    selected_ids = location.selected_ids
    # get results from taxable_taxonomies
    environment_ids = location.environments.pluck(:id)
    hostgroup_ids = location.hostgroups.pluck(:id)
    subnet_ids = location.subnets.pluck(:id)
    domain_ids = location.domains.pluck(:id)
    medium_ids = location.media.pluck(:id)
    user_ids = location.users.pluck(:id)
    smart_proxy_ids = location.smart_proxies.pluck(:id)
    config_template_ids = location.config_templates.pluck(:id)
    compute_resource_ids = location.compute_resources.pluck(:id)
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
    location = taxonomies(:location1)
    # ignore all types
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    # run selected_ids method
    selected_ids = location.selected_ids
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

end
