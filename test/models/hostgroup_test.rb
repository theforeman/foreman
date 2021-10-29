require 'test_helper'

# Generates a list of valid host group names.
def valid_hostgroup_name_list
  # Note::
  # Host group name max length is 245 chars.
  # 220 chars for html as the largest html tag in fauxfactory is 10 chars long,
  # so 245 - (10 chars + 10 chars + '<></>' chars) = 220 chars.
  [
    RFauxFactory.gen_alpha(1),
    RFauxFactory.gen_alpha(245),
    *RFauxFactory.gen_strings(1..245, exclude: [:html, :punctuation]).values,
    RFauxFactory.gen_html(rand((1..220))),
  ]
end

class HostgroupTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).scoped_to(:ancestry).case_insensitive
  should allow_values(*valid_hostgroup_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)
  should allow_value(nil).for(:root_pass)
  should validate_length_of(:root_pass).is_at_least(8).
    with_message('should be 8 characters or more')

  test 'hooks are defined' do
    expected = [
      'hostgroup_created.event.foreman',
      'hostgroup_updated.event.foreman',
      'hostgroup_destroyed.event.foreman',
    ]

    assert_same_elements expected, Hostgroup.event_subscription_hooks
  end

  test "name strips leading and trailing white spaces" do
    host_group = Hostgroup.new :name => " all    hosts in the     world    "
    assert host_group.save
    refute host_group.name.ends_with?(' ')
    refute host_group.name.starts_with?(' ')
  end

  test "should be able to nest a group parameters" do
    # creates a 3 level hirecy, each one with his own parameters
    # and overrides.
    pid = Time.now.to_i
    top = Hostgroup.new(:name => "topA",
                        :group_parameters_attributes => { pid += 1 => {"name" => "topA", "value" => "1"},
                                                          pid += 1 => {"name" => "topB", "value" => "1"},
                                                          pid += 1 => {"name" => "topC", "value" => "1"}})
    assert top.save

    second = Hostgroup.new(:name => "SecondA", :parent_id => top.id,
                           :group_parameters_attributes => { pid += 1 => {"name" => "topA", "value" => "2"},
                                                             pid += 1 => {"name" => "secondA", "value" => "2"}})
    assert second.save

    assert second.parameters.include? "topA"
    assert_equal "2", second.parameters["topA"]
    assert second.parameters.include? "topB"
    assert_equal "1", second.parameters["topB"]
    assert second.parameters.include? "topC"
    assert_equal "1", second.parameters["topC"]
    assert second.parameters.include? "secondA"
    assert_equal "2", second.parameters["secondA"]

    third = Hostgroup.new(:name => "ThirdA", :parent_id => second.id,
                          :group_parameters_attributes => { pid += 1 => {"name" => "topB", "value" => "3"},
                                                            pid +  1 => {"name" => "topA", "value" => "3"}})
    assert third.save

    assert third.parameters.include? "topA"
    assert_equal "3", third.parameters["topA"]
    assert third.parameters.include? "topB"
    assert_equal "3", third.parameters["topB"]
    assert third.parameters.include? "topC"
    assert_equal "1", third.parameters["topC"]
    assert third.parameters.include? "secondA"
    assert_equal "2", third.parameters["secondA"]
  end

  test "should show parent parameters" do
    pid = Time.now.to_i
    child = nil

    as_admin do
      top = FactoryBot.create(:hostgroup, :name => "topA",
                               :group_parameters_attributes => { pid += 1 => {"name" => "topA", "value" => "1"},
                                                                 pid += 1 => {"name" => "topB", "value" => "1"}})
      child = Hostgroup.create!(:name => "secondB", :parent_id => top.id)
    end

    assert_equal({ "topA" => "1", "topB" => "1" }, child.parent_params)
  end

  test "blocks deletion of hosts with children" do
    top = Hostgroup.create(:name => "topA")
    Hostgroup.create(:name => "secondB", :parent_id => top.id)

    assert top.has_children?
    assert_raise Ancestry::AncestryException do
      top.destroy
    end
  end

  test "changing name of hostgroup updates other hostgroup labels" do
    # setup - add parent to hostgroup :common (not in fixtures, since no field parent_id)
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!

    # change name of parent
    assert parent_hostgroup.update(:name => "new_common")
    # check if hostgroup(:db) label changed
    hostgroup.reload
    assert_equal "new_common/db", hostgroup.title
  end

  test "deleting a hostgroup with children does not change labels" do
    # setup - get label "common/db"
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!
    hostgroup.reload
    assert_equal "Common/db", hostgroup.title

    # attempt to destroy parent hostgroup
    begin
      assert_not parent_hostgroup.destroy
    rescue Ancestry::AncestryException
    end
    # check if hostgroup(:db) label remains the same
    hostgroup.reload
    assert_equal "Common/db", hostgroup.title
  end

  test "should find associated lookup_values" do
    assert_equal [lookup_values(:hostgroupcommon), lookup_values(:four)].map(&:id).sort, hostgroups(:common).lookup_values.map(&:id).sort
  end

  test "should find associated lookup_values with unsafe SQL name" do
    hostgroup = hostgroups(:common)
    hostgroup.name = "Robert';"
    hostgroup.save!
    lv = lookup_values(:four)
    lv.match = "hostgroup=#{hostgroup.name}"
    lv.save!
    assert_equal [lookup_values(:hostgroupcommon), lookup_values(:four)].map(&:id).sort, hostgroup.lookup_values.map(&:id).sort
  end

  # test NestedAncestryCommon methods generate by class method nested_attribute_for
  test "respond to nested_attribute_for methods" do
    hostgroup = hostgroups(:common)
    [:compute_profile_id, :domain_id, :puppet_ca_proxy_id, :operatingsystem_id,
     :architecture_id, :medium_id, :ptable_id, :subnet_id, :subnet6_id].each do |field|
      assert hostgroup.respond_to?("inherited_#{field}")
    end
  end

  test "inherited id value equals field id value if no ancestry" do
    hostgroup = hostgroups(:parent)
    [:compute_profile_id, :domain_id, :puppet_ca_proxy_id, :operatingsystem_id,
     :architecture_id, :medium_id, :ptable_id, :subnet_id, :subnet6_id].each do |field|
      refute_nil hostgroup.send(field), "missing #{field}"
      assert_equal hostgroup.send(field), hostgroup.send("inherited_#{field}")
    end
  end

  test "inherited id value equals parent's field id value if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    [:compute_profile_id, :domain_id, :puppet_ca_proxy_id, :operatingsystem_id,
     :architecture_id, :medium_id, :ptable_id, :subnet_id, :subnet6_id].each do |field|
      refute_nil parent.send(field), "missing #{field}"
      assert_equal parent.send(field), child.send("inherited_#{field}")
    end
  end

  test "inherited id value does not inherit parent's field id value if the child's value is not null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    child.update(domain_id: domains(:yourdomain).id)
    child.reload
    # only domain_id is overriden in inherited fixture
    refute_equal parent.domain_id, child.inherited_domain_id
    assert_equal child.domain_id, child.inherited_domain_id
  end

  test "inherited object equals parent object if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    # methods below do not include _id
    # environment is not included in the array below since child value is not null
    [:compute_profile, :domain, :puppet_ca_proxy, :operatingsystem,
     :architecture, :medium, :ptable, :subnet, :subnet6].each do |field|
      refute_nil parent.send(field), "missing #{field}"
      assert_equal parent.send(field), child.send(field)
    end
  end

  test "inherited object does not inherit parent object if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    child.update(domain: domains(:yourdomain))
    child.reload
    refute_equal parent.domain, child.domain
    assert_equal domains(:yourdomain), child.domain
  end

  test "root_pass inherited from parent if blank" do
    parent = FactoryBot.create(:hostgroup, :root_pass => '12345678')
    hostgroup = FactoryBot.build(:hostgroup, :parent => parent, :root_pass => '')
    assert_equal parent.read_attribute(:root_pass), hostgroup.root_pass
    hostgroup.save!
    assert hostgroup.read_attribute(:root_pass).blank?, 'root_pass should not be copied and stored on child'
  end

  test "root_pass inherited from settings if blank" do
    Setting[:root_pass] = '12345678'
    PasswordCrypt.expects(:crypt_gnu_compatible?).at_least_once.returns(true)
    PasswordCrypt.expects(:passw_crypt).with(Setting[:root_pass]).at_least_once.returns(Setting[:root_pass])
    hostgroup = FactoryBot.build(:hostgroup, :root_pass => '')
    assert_equal '12345678', hostgroup.root_pass
    hostgroup.save!
    assert hostgroup.read_attribute(:root_pass).blank?, 'root_pass should not be copied and stored on child'
  end

  test "root_pass inherited from settings if group and parent are blank" do
    Setting[:root_pass] = '12345678'
    PasswordCrypt.expects(:crypt_gnu_compatible?).at_least_once.returns(true)
    PasswordCrypt.expects(:passw_crypt).with(Setting[:root_pass]).at_least_once.returns(Setting[:root_pass])
    parent = FactoryBot.create(:hostgroup, :root_pass => '')
    hostgroup = FactoryBot.build(:hostgroup, :parent => parent, :root_pass => '')
    assert_equal '12345678', hostgroup.root_pass
    hostgroup.save!
    assert hostgroup.read_attribute(:root_pass).blank?, 'root_pass should not be copied and stored on child'
  end

  test "hostgroup name can be up to 255 characters" do
    parent = FactoryBot.create(:hostgroup)
    min_lookupvalue_length = "hostgroup=".length + parent.title.length + 1
    hostgroup = Hostgroup.new :parent => parent, :name => 'a' * (255 - min_lookupvalue_length)
    assert_valid hostgroup
  end

  test "to_param" do
    parent = FactoryBot.create(:hostgroup, :name => 'a')
    hostgroup = Hostgroup.new(:parent => parent, :name => 'b')
    assert_equal "#{hostgroup.id}-a-b",  hostgroup.to_param
  end

  test "to_param calls ancestry when title is not yet saved" do
    parent = FactoryBot.create(:hostgroup, :name => 'a')
    hostgroup = Hostgroup.new(:parent => parent, :name => 'b')
    hostgroup.expects(:ancestry).once
    hostgroup.to_param
  end

  test "to_param doesn't call ancestry when title is saved" do
    parent = FactoryBot.create(:hostgroup, :name => 'a')
    hostgroup = Hostgroup.create(:parent => parent, :name => 'b')
    hostgroup.expects(:ancestry).never
    hostgroup.to_param
  end

  test 'with both subnet and subnet6 should be valid if VLAN ID is consistent between subnets' do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :vlanid => 14)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => 14)
    hostgroup = FactoryBot.build(:hostgroup, :subnet => subnet, :subnet6 => subnet6)
    assert_valid hostgroup
  end

  test 'with both subnet and subnet6 should not be valid if VLAN ID mismatch between subnets' do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :vlanid => 3)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => 4)
    hostgroup = FactoryBot.build(:hostgroup, :subnet => subnet, :subnet6 => subnet6)
    refute_valid hostgroup
    assert_includes hostgroup.errors.keys, :subnet_id

    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :vlanid => nil)
    hostgroup = FactoryBot.build(:hostgroup, :subnet => subnet, :subnet6 => subnet6)
    refute_valid hostgroup
    assert_includes hostgroup.errors.keys, :subnet_id
  end

  test 'with both subnet and subnet6 should be valid if MTU is consistent between subnets' do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :mtu => 1496)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :mtu => 1496)
    hostgroup = FactoryBot.build(:hostgroup, :subnet => subnet, :subnet6 => subnet6)
    assert_valid hostgroup
  end

  test 'with both subnet and subnet6 should not be valid if MTU mismatch between subnets' do
    domain = FactoryBot.create(:domain)
    subnet = FactoryBot.create(:subnet_ipv4, :domains => [domain], :mtu => 1496)
    subnet6 = FactoryBot.create(:subnet_ipv6, :domains => [domain], :mtu => 1500)
    hostgroup = FactoryBot.build(:hostgroup, :subnet => subnet, :subnet6 => subnet6)
    refute_valid hostgroup
    assert_includes hostgroup.errors.keys, :subnet_id
  end

  context "#clone" do
    let(:group) { FactoryBot.create(:hostgroup, :name => 'a') }

    test "clone should clone parameters values but update ids" do
      group.group_parameters.create!(:name => "foo", :value => "bar")
      cloned = group.clone("new_name")
      cloned.save
      assert_equal cloned.group_parameters.map { |p| [p.name, p.value] }, group.group_parameters.map { |p| [p.name, p.value] }
      refute_equal cloned.group_parameters.map { |p| p.id }, group.group_parameters.map { |p| p.id }
      refute_equal cloned.group_parameters.map { |p| p.reference_id }, group.group_parameters.map { |p| p.reference_id }
    end

    test "clone should clone lookup values" do
      lv = lookup_values(:four)
      lv.match = group.send(:lookup_value_match)
      lv.save!
      cloned = group.clone("new_name")
      cloned.save!
      assert_equal 1, group.lookup_values.reload.count
      assert_equal 1, cloned.lookup_values.count
      assert_equal group.lookup_values.map(&:value), cloned.lookup_values.map(&:value)
    end

    test 'without save makes no changes' do
      group = FactoryBot.create(:hostgroup)
      FactoryBot.create(:lookup_key, :with_override, path: "hostgroup\ncomment", overrides: { group.lookup_value_matcher => 'test' })
      ActiveRecord::Base.any_instance.expects(:destroy).never
      ActiveRecord::Base.any_instance.expects(:save).never
      group.clone
    end
  end

  test '#children_hosts_count' do
    group = FactoryBot.create(:hostgroup, :with_parent, :with_os, :with_domain)
    FactoryBot.create_list(:host, 3, :managed, :hostgroup => group)
    assert_equal(3, group.parent.children_hosts_count)
    nested_group = FactoryBot.create(:hostgroup, :parent => group)
    FactoryBot.create_list(:host, 4, :managed, :hostgroup => nested_group)
    assert_equal(7, group.parent.children_hosts_count)
  end

  test "should not associate proxies without appropriate features" do
    proxy = smart_proxies(:one)
    hostgroup = Hostgroup.new(:name => ".otherDomain.", :puppet_proxy_id => proxy.id, :puppet_ca_proxy_id => proxy.id)
    refute hostgroup.save
    assert_equal "does not have the Puppet feature", hostgroup.errors["puppet_proxy_id"].first
    assert_equal "does not have the Puppet CA feature", hostgroup.errors["puppet_ca_proxy_id"].first
  end

  test 'should be invalid when subnet types are wrong' do
    hostgroup = FactoryBot.build_stubbed(:hostgroup)
    subnetv4 = Subnet::Ipv4.new
    subnetv6 = Subnet::Ipv6.new

    hostgroup.subnet = subnetv6
    hostgroup.subnet6 = subnetv4

    refute hostgroup.valid?, "Can't be valid with invalid subnet types: #{hostgroup.errors.messages}"
    assert_includes hostgroup.errors.keys, :subnet
    assert_includes hostgroup.errors.keys, :subnet6
  end

  context "recreating host configs" do
    setup do
      @hostgroup = FactoryBot.create(:hostgroup, :with_parent)
      @host = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup)
      @host2 = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup.parent)
    end

    test "recreate config with success - only empty" do
      Host::Managed.any_instance.expects(:recreate_config).returns({"TFTP" => true, "DHCP" => true, "DNS" => true}).once
      result = @hostgroup.recreate_hosts_config()
      assert result[@host.name]["DHCP"]
      assert result[@host.name]["DNS"]
      assert result[@host.name]["TFTP"]
    end

    test "recreate config with success - only TFTP" do
      Host::Managed.any_instance.expects(:recreate_config).returns({"TFTP" => true}).once
      result = @hostgroup.recreate_hosts_config(['TFTP'])
      refute result[@host.name]["DHCP"]
      refute result[@host.name]["DNS"]
      assert result[@host.name]["TFTP"]
    end

    test 'recreate children hostgroup hosts' do
      Host::Managed.any_instance.expects(:recreate_config).returns({"TFTP" => true, "DHCP" => true, "DNS" => true}).twice
      result = @hostgroup.parent.recreate_hosts_config(nil, true)
      assert result[@host.name]["DHCP"]
      assert result[@host.name]["DNS"]
      assert result[@host.name]["TFTP"]
      assert result[@host2.name]["DHCP"]
      assert result[@host2.name]["DNS"]
      assert result[@host2.name]["TFTP"]
    end
  end

  test "can search hostgroup by params" do
    hg1 = FactoryBot.create(:hostgroup)
    hg1.group_parameters.create!(:name => "foo", :value => "bar")
    parameter = hg1.group_parameters.first
    hg2 = FactoryBot.create(:hostgroup)
    hg2.group_parameters.create!(:name => "foo", :value => "test")

    results = Hostgroup.search_for(%{params.#{parameter.name} = "#{parameter.searchable_value}"})
    assert results.include?(hg1)
    refute results.include?(hg2)
  end

  private

  def setup_user(operation)
    super operation, "hostgroups"
  end
end
