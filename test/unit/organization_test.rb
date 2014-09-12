require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  setup do
    User.current = users :admin
  end

  test 'it should not save with an empty name' do
    organization = Organization.new
    refute organization.save
  end

  test 'it should not save with a blank name' do
    organization = Organization.new(:name => '   ')
    refute organization.save
  end

  test 'it should not save another organization with the same name if no parent' do
    organization = Organization.new(:name => 'Organization 1')
    refute organization.save
  end

  test 'name can be the same if parent is different' do
    assert_difference('Organization.count', 2) do
      assert subloc1 = Organization.create!(:name => "Department A", :parent_id => taxonomies(:organization1).id)
      assert subloc2 = Organization.create!(:name => "Department A", :parent_id => taxonomies(:organization2).id)
      assert_equal 'Organization 1/Department A', subloc1.title
      assert_equal 'Organization 2/Department A', subloc2.title
    end
  end

  test 'it should show the name for to_s' do
    organization = Organization.new :name => "organization1"
    assert organization.to_s == "organization1"
  end

  test 'organization is valid if ignore all types' do
    organization = taxonomies(:organization1)
    organization.location_ids = [taxonomies(:location1).id]
    organization.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    assert organization.valid?
  end

  test 'organization is valid after fixture mismatches' do
    organization = taxonomies(:organization1)
    Taxonomy.all_import_missing_ids
    assert organization.valid?
  end

  test 'it should return array of used ids by hosts' do
    organization = taxonomies(:organization1)
    FactoryGirl.create(:host,
                       :compute_resource => compute_resources(:one),
                       :domain           => domains(:mydomain),
                       :environment      => environments(:production),
                       :medium           => media(:one),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :organization     => organization,
                       :owner            => users(:restricted),
                       :puppet_proxy     => smart_proxies(:puppetmaster),
                       :realm            => realms(:myrealm),
                       :subnet           => subnets(:one))
    FactoryGirl.create(:os_default_template,
                       :config_template  => config_templates(:mystring2),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :template_kind    => TemplateKind.find_by_name('provision'))
    # run used_ids method
    used_ids = organization.used_ids
    # get results from Host object
    environment_ids = Host.where(:organization_id => organization.id).pluck(:environment_id).compact.uniq
    hostgroup_ids = Host.where(:organization_id => organization.id).pluck(:hostgroup_id).compact.uniq
    subnet_ids = Host.where(:organization_id => organization.id).pluck(:subnet_id).compact.uniq
    domain_ids = Host.where(:organization_id => organization.id).pluck(:domain_id).compact.uniq
    realm_ids = Host.where(:organization_id => organization.id).pluck(:realm_id).compact.uniq
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
    assert_equal used_ids[:realm_ids], realm_ids
    assert_equal used_ids[:medium_ids], medium_ids
    assert_equal used_ids[:compute_resource_ids], compute_resource_ids
    assert_equal used_ids[:user_ids].sort, user_ids.sort
    assert_equal used_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
    assert_equal used_ids[:config_template_ids], config_template_ids
    # match to raw fixtures data
    assert_equal used_ids[:environment_ids].sort, [environments(:production).id]
    assert_equal used_ids[:hostgroup_ids].sort, []
    assert_equal used_ids[:subnet_ids], [subnets(:one).id]
    assert_equal used_ids[:domain_ids], [domains(:mydomain).id]
    assert_equal used_ids[:medium_ids], [media(:one).id]
    assert_equal used_ids[:compute_resource_ids].sort, [compute_resources(:one).id]
    assert_equal used_ids[:user_ids], [users(:restricted).id]
    assert_equal used_ids[:smart_proxy_ids].sort, [smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:puppetmaster).id, smart_proxies(:realm).id].sort
    assert_equal used_ids[:config_template_ids].sort, [config_templates(:mystring2).id]
  end

  test 'it should return selected_ids array of selected values only (when types are not ignored)' do
    organization = taxonomies(:organization1)
    #fixtures for taxable_taxonomies don't work, on has_many :through polymorphic
    # run selected_ids method
    selected_ids = organization.selected_ids
    # get results from taxable_taxonomies
    environment_ids = organization.environment_ids
    hostgroup_ids = organization.hostgroup_ids
    subnet_ids = organization.subnet_ids
    domain_ids = organization.domain_ids
    realm_ids = organization.realm_ids
    medium_ids = organization.medium_ids
    user_ids = organization.user_ids
    smart_proxy_ids = organization.smart_proxy_ids
    config_template_ids = organization.config_template_ids
    compute_resource_ids = organization.compute_resource_ids
    # check if they match
    assert_equal selected_ids[:environment_ids].sort, environment_ids.sort
    assert_equal selected_ids[:hostgroup_ids].sort, hostgroup_ids.sort
    assert_equal selected_ids[:subnet_ids].sort, subnet_ids.sort
    assert_equal selected_ids[:domain_ids].sort, domain_ids.sort
    assert_equal selected_ids[:realm_ids].sort, realm_ids.sort
    assert_equal selected_ids[:medium_ids].sort, medium_ids.sort
    assert_equal selected_ids[:user_ids].sort, user_ids.sort
    assert_equal selected_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
    assert_equal selected_ids[:config_template_ids].sort, config_template_ids.sort
    assert_equal selected_ids[:compute_resource_ids].sort, compute_resource_ids.sort
    # match to manually generated taxable_taxonomies
    assert_equal selected_ids[:environment_ids], [environments(:production).id]
    assert_equal selected_ids[:hostgroup_ids], []
    assert_equal selected_ids[:subnet_ids], [subnets(:one).id]
    assert_equal selected_ids[:domain_ids], [domains(:mydomain).id]
    assert_equal selected_ids[:medium_ids], []
    assert_equal selected_ids[:user_ids], []
    assert_equal selected_ids[:smart_proxy_ids].sort, [smart_proxies(:puppetmaster).id, smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:realm).id].sort
    assert_equal selected_ids[:config_template_ids], [config_templates(:mystring2).id]
    assert_equal selected_ids[:compute_resource_ids], [compute_resources(:one).id]
  end

  test 'it should return selected_ids array of ALL values (when types are ignored)' do
    organization = taxonomies(:organization1)
    # ignore all types
    organization.ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    # run selected_ids method
    selected_ids = organization.selected_ids
    # should return all when type is ignored
    assert_equal selected_ids[:environment_ids], Environment.pluck(:id)
    assert_equal selected_ids[:hostgroup_ids], Hostgroup.pluck(:id)
    assert_equal selected_ids[:subnet_ids], Subnet.pluck(:id)
    assert_equal selected_ids[:domain_ids], Domain.pluck(:id)
    assert_equal selected_ids[:realm_ids], Realm.pluck(:id)
    assert_equal selected_ids[:medium_ids], Medium.pluck(:id)
    assert_equal selected_ids[:user_ids], User.pluck(:id)
    assert_equal selected_ids[:smart_proxy_ids], SmartProxy.pluck(:id)
    assert_equal selected_ids[:config_template_ids], ConfigTemplate.pluck(:id)
    assert_equal selected_ids[:compute_resource_ids], ComputeResource.pluck(:id)
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

  test "non-admin user is added to organization after creating it" do
    user = User.current = users(:one)
    refute user.admin?
    assert organization = Organization.create(:name => 'new organization')
    assert organization.users.include?(user)
  end

  test ".my_organizations returns all orgs for admin" do
    as_admin do
      assert_equal Organization.unscoped.pluck(:id).sort, Organization.my_organizations.pluck(:id).sort
    end
  end

  test ".my_organizations returns user's associated orgs and children" do
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization, :parent => org1)
    user = FactoryGirl.create(:user, :organizations => [org1])
    as_user(user) do
      assert_equal [org1.id, org2.id].sort, Organization.my_organizations.pluck(:id).sort
    end
  end

end
