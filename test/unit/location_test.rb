require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

# MOVE TEST TO TAXONOMY
  test 'location is valid after fixture mismatches' do
    location = taxonomies(:location1)
    Taxonomy.all_import_missing_ids
    assert location.valid?
  end

  test 'location is valid if ignore all types' do
    location = taxonomies(:location1)
    location.organization_ids = [taxonomies(:organization1).id]
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    assert location.valid?
  end

  test 'it should return selected_ids array of ALL values (when types are ignored)' do
    location = taxonomies(:location1)
    # ignore all types
    location.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    # run selected_ids method
    selected_ids = location.selected_ids
    # should return all when type is ignored
    assert_equal selected_ids[:environment_ids].sort, Environment.pluck(:id).sort
    assert_equal selected_ids[:hostgroup_ids].sort, Hostgroup.pluck(:id).sort
    assert_equal selected_ids[:subnet_ids].sort, Subnet.pluck(:id).sort
    assert_equal selected_ids[:domain_ids].sort, Domain.pluck(:id).sort
    assert_equal selected_ids[:realm_ids].sort, Realm.pluck(:id).sort
    assert_equal selected_ids[:medium_ids].sort, Medium.pluck(:id).sort
    assert_equal selected_ids[:user_ids].sort, User.pluck(:id).sort
    assert_equal selected_ids[:smart_proxy_ids].sort, SmartProxy.pluck(:id).sort
    assert_equal selected_ids[:config_template_ids].sort, ConfigTemplate.pluck(:id).sort
    assert_equal selected_ids[:compute_resource_ids].sort, ComputeResource.pluck(:id).sort
  end


# END MOVE TEST TO TAXONOMY
  #
  #Audit
  test "it should have auditable_type as Location rather Taxonomy" do
    location = taxonomies(:location2)
    assert location.update_attributes!(:name => 'newname')
    assert_equal 'Location', Audit.unscoped.last.auditable_type
  end

  #Location inheritance tests
  test "inherited location should have correct path" do
    parent = taxonomies(:location1)
    location = Location.create!(:name => "rack1", :parent_id => parent.id)
    assert_equal "Location 1/rack1", location.title
  end

  test "inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # check that inherited_ids of location matches selected_ids of parent
    assert_equal parent.selected_ids, location.inherited_ids
  end

  test "selected_or_inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # add subnet to location
    assert TaxableTaxonomy.create(:taxonomy_id => location.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
    # check that inherited_ids of location matches selected_ids of parent, except for subnet
    location.selected_or_inherited_ids.each do |k,v|
      assert_equal v.uniq, parent.selected_ids[k].uniq unless k == 'subnet_ids'
      assert_equal v.uniq, ([subnets(:two).id] + parent.selected_ids[k].uniq) if k == 'subnet_ids'
    end
  end

  test "used_and_selected_or_inherited_ids for inherited location" do
    parent = taxonomies(:location1)
    subnet = FactoryGirl.create(:subnet)
    domain1 = FactoryGirl.create(:domain)
    domain2 = FactoryGirl.create(:domain)
    parent.update_attribute(:domains,[domain1,domain2])
    parent.update_attribute(:subnets,[subnet])
    # we're no longer using the fixture dhcp/dns/tftp proxy to create the host, so remove them
    parent.update_attribute(:smart_proxies,[smart_proxies(:puppetmaster),smart_proxies(:realm)])

    location = Location.create :name => "rack1", :parent_id => parent.id
    FactoryGirl.create(:host,
                       :compute_resource => compute_resources(:one),
                       :domain           => domain1,
                       :environment      => environments(:production),
                       :location         => parent,
                       :organization     => taxonomies(:organization1),
                       :medium           => media(:one),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :owner            => users(:restricted),
                       :puppet_proxy     => smart_proxies(:puppetmaster),
                       :realm            => realms(:myrealm),
                       :subnet           => subnet)
    FactoryGirl.create(:host,
                       :location         => parent,
                       :domain           => domain2)
    FactoryGirl.create(:os_default_template,
                       :config_template  => config_templates(:mystring2),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :template_kind    => TemplateKind.find_by_name('provision'))

    # check that inherited_ids of location matches selected_ids of parent
    location.selected_or_inherited_ids.each do |k,v|
      assert_equal v.sort, parent.used_and_selected_ids[k].sort
    end
  end

  test "need_to_be_selected_ids for inherited location" do
    parent = taxonomies(:location1)
    location = Location.create :name => "rack1", :parent_id => parent.id
    # no hosts were assigned to location, so no missing ids need to be selected
    location.need_to_be_selected_ids.each do |k,v|
      assert v.empty?
    end
  end

  test "multiple inheritence" do
    parent1 = taxonomies(:location1)
    assert_equal [subnets(:one).id], parent1.selected_ids["subnet_ids"]

    # inherit from parent 1
    parent2 = Location.create :name => "floor1", :parent_id => parent1.id
    assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
    assert_equal [subnets(:one).id, subnets(:two).id].sort, parent2.selected_or_inherited_ids["subnet_ids"].sort

    # inherit from parent 2
    location = Location.create :name => "rack1", :parent_id => parent2.id
    assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:three).id, :taxable_type => "Subnet")
    assert_equal [subnets(:one).id, subnets(:two).id, subnets(:three).id].sort, location.selected_or_inherited_ids["subnet_ids"].sort
  end

  test "parameter inheritence with no new parameters on child location" do
    assert_equal [parameters(:location)], taxonomies(:location1).location_parameters

    # inherit parameter from parent
    location = Location.create :name => "floor1", :parent_id => taxonomies(:location1).id
    assert_equal [], location.location_parameters
    assert_equal Hash['loc_param', 'abc'], location.parameters
  end

  test "parameter inheritence with new parameters on child location" do
    assert_equal [parameters(:location)], taxonomies(:location1).location_parameters

    # inherit parameter from parent
    child_location = Location.create :name => "floor1", :parent_id => taxonomies(:location1).id
    assert_equal [], child_location.location_parameters

    # new parameter on child location
    child_location.location_parameters.create(:name => "child_param", :value => "123")

    assert_equal Hash['loc_param', 'abc', 'child_param', '123'], child_location.parameters
  end

  test "non-admin user is added to location after creating it" do
    user = User.current = users(:one)
    refute user.admin?
    assert location = Location.create(:name => 'new location')
    assert location.users.include?(user)
  end

  test "location name can't be too big to create lookup value matcher over 255 characters" do
    parent = FactoryGirl.create(:location)
    min_lookupvalue_length = "location=".length + parent.title.length + 1
    location = Location.new :parent => parent, :name => 'a' * 256
    refute_valid location
    assert_equal "is too long (maximum is %s characters)" % (255 -  min_lookupvalue_length), location.errors[:name].first
  end

  test "location name can be up to 255 characters" do
    parent = FactoryGirl.create(:location)
    min_lookupvalue_length = "location=".length + parent.title.length + 1
    location = Location.new :parent => parent, :name => 'a' * (255 - min_lookupvalue_length)
    assert_valid location
  end

  test "location should not save when matcher is exactly 256 characters" do
    parent = FactoryGirl.create(:location, :name => 'a' * 245)
    location = Location.new :parent => parent, :name => 'b'
    refute_valid location
    assert_equal _("is too long (maximum is 0 characters)"),  location.errors[:name].first
  end

  test ".my_locations returns all locations for admin" do
    as_admin do
      assert_equal Location.unscoped.pluck(:id).sort, Location.my_locations.pluck(:id).sort
    end
  end

  test ".my_locations returns user's associated locations and children" do
    loc1 = FactoryGirl.create(:location)
    loc2 = FactoryGirl.create(:location, :parent => loc1)
    user = FactoryGirl.create(:user, :locations => [loc1])
    as_user(user) do
      assert_equal [loc1.id, loc2.id].sort, Location.my_locations.pluck(:id).sort
    end
  end
end
