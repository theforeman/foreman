require 'test_helper'

class TaxHostTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test 'it should return array of used ids by hosts' do
    location = taxonomies(:location1)
    FactoryGirl.create(:host,
                       :compute_resource => compute_resources(:one),
                       :domain           => domains(:mydomain),
                       :environment      => environments(:production),
                       :location         => location,
                       :medium           => media(:one),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :owner            => users(:restricted),
                       :puppet_proxy     => smart_proxies(:puppetmaster),
                       :realm            => realms(:myrealm),
                       :subnet           => subnets(:one))
    FactoryGirl.create(:os_default_template,
                       :config_template  => config_templates(:mystring2),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :template_kind    => TemplateKind.find_by_name('provision'))
    used_ids = location.used_ids
    # get results from Host object
    environment_ids      = Host.where(:location_id => location.id).pluck(:environment_id).compact.uniq
    hostgroup_ids        = Host.where(:location_id => location.id).pluck(:hostgroup_id).compact.uniq
    subnet_ids           = Host.where(:location_id => location.id).pluck(:subnet_id).compact.uniq
    domain_ids           = Host.where(:location_id => location.id).pluck(:domain_id).compact.uniq
    realm_ids            = Host.where(:location_id => location.id).pluck(:realm_id).compact.uniq
    medium_ids           = Host.where(:location_id => location.id).pluck(:medium_id).compact.uniq
    compute_resource_ids = Host.where(:location_id => location.id).pluck(:compute_resource_id).compact.uniq
    user_ids             = Host.where(:location_id => location.id).where(:owner_type => 'User').pluck(:owner_id).compact.uniq
    smart_proxy_ids      = Host.where(:location_id => location.id).map {|host| host.smart_proxies.map(&:id)}.flatten.compact.uniq
    config_template_ids  = Host.where("location_id = #{location.id} and operatingsystem_id > 0").map {|host| host.configTemplate.try(:id)}.compact.uniq
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
    assert_equal used_ids[:hostgroup_ids], []
    assert_equal used_ids[:subnet_ids], [subnets(:one).id]
    assert_equal used_ids[:domain_ids], [domains(:mydomain).id]
    assert_equal used_ids[:medium_ids], [media(:one).id]
    assert_equal used_ids[:compute_resource_ids], [compute_resources(:one).id]
    assert_equal used_ids[:user_ids], [users(:restricted).id]
    assert_equal used_ids[:smart_proxy_ids].sort, [smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:puppetmaster).id, smart_proxies(:realm).id].sort
    assert_equal used_ids[:config_template_ids], [config_templates(:mystring2).id]
  end

  test 'it should return selected_ids array of selected values only (when types are not ignored)' do
    location = taxonomies(:location1)
    # run selected_ids method
    selected_ids = location.selected_ids
    # get results from taxable_taxonomies
    environment_ids = location.environments.pluck('environments.id')
    hostgroup_ids = location.hostgroups.pluck('hostgroups.id')
    subnet_ids = location.subnets.pluck('subnets.id')
    domain_ids = location.domains.pluck('domains.id')
    medium_ids = location.media.pluck('media.id')
    user_ids = location.users.pluck('users.id')
    smart_proxy_ids = location.smart_proxies.pluck('smart_proxies.id')
    config_template_ids = location.config_templates.pluck('config_templates.id')
    compute_resource_ids = location.compute_resources.pluck('compute_resources.id')
    # check if they match
    assert_equal selected_ids[:environment_ids].sort, environment_ids.sort
    assert_equal selected_ids[:hostgroup_ids].sort, hostgroup_ids.sort
    assert_equal selected_ids[:subnet_ids].sort, subnet_ids.sort
    assert_equal selected_ids[:domain_ids].sort, domain_ids.sort
    assert_equal selected_ids[:medium_ids].sort, medium_ids.sort
    assert_equal selected_ids[:user_ids].sort, user_ids.sort
    assert_equal selected_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
    assert_equal selected_ids[:config_template_ids].sort, config_template_ids.sort
    assert_equal selected_ids[:compute_resource_ids].sort, compute_resource_ids.sort
    # match to manually generated taxable_taxonomies
    assert_equal selected_ids[:environment_ids], [environments(:production).id]
    assert_equal selected_ids[:hostgroup_ids], []
    assert_equal selected_ids[:subnet_ids], [subnets(:one).id]
    assert_equal selected_ids[:domain_ids].sort, [domains(:mydomain).id, domains(:yourdomain).id].sort
    assert_equal selected_ids[:medium_ids], [media(:one).id]
    assert_equal selected_ids[:user_ids], []
    assert_equal selected_ids[:smart_proxy_ids].sort, [smart_proxies(:puppetmaster).id, smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:realm).id].sort
    assert_equal selected_ids[:config_template_ids], [config_templates(:mystring2).id]
    assert_equal selected_ids[:compute_resource_ids], [compute_resources(:one).id]
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
    location = Location.create :name => "rack1", :parent_id => parent.id
    FactoryGirl.create(:host,
                       :compute_resource => compute_resources(:one),
                       :domain           => domains(:mydomain),
                       :environment      => environments(:production),
                       :location         => parent,
                       :organization     => taxonomies(:organization1),
                       :medium           => media(:one),
                       :operatingsystem  => operatingsystems(:centos5_3),
                       :owner            => users(:restricted),
                       :puppet_proxy     => smart_proxies(:puppetmaster),
                       :realm            => realms(:myrealm),
                       :subnet           => subnets(:one))
    FactoryGirl.create(:host,
                       :location         => parent,
                       :domain           => domains(:yourdomain))
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
end
