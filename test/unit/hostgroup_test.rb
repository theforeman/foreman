require 'test_helper'

class HostgroupTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "name can't be blank" do
    host_group = Hostgroup.new :name => "  "
    assert host_group.name.strip.empty?
    assert !host_group.save
  end

  test "name can't contain trailing white spaces" do
    host_group = Hostgroup.new :name => " all    hosts in the     world    "
    assert !host_group.name.squeeze(" ").empty?
    assert !host_group.save

    host_group.name.squeeze!(" ")
    assert host_group.save
  end

  test "name must be unique" do
    host_group = Hostgroup.new :name => "some hosts"
    assert host_group.save

    other_host_group = Hostgroup.new :name => "some hosts"
    assert !other_host_group.save
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_hostgroup"
      role.permissions = ["#{operation}_hostgroups".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Hostgroup.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Hostgroup.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record = hostgroups(:common)
    as_admin do
      record.hosts.destroy_all
      record.hostgroup_classes.destroy_all
      assert record.destroy
    end
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record = hostgroups(:common)
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Hostgroup.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Hostgroup.first
    record.name = "renamed"
    as_admin do
      record.hosts.destroy_all
    end
    assert !record.save
    assert record.valid?
  end

  test "should be able to nest a group parameters" do
    # creates a 3 level hirecy, each one with his own parameters
    # and overrides.
    pid = Time.now.to_i
    assert (top = Hostgroup.create(:name => "topA", :group_parameters_attributes => {
      pid += 1=>{"name"=>"topA", "value"=>"1", :nested => ""},
      pid += 1=>{"name"=>"topB", "value"=>"1", :nested => ""},
      pid += 1=>{"name"=>"topC", "value"=>"1", :nested => ""},
    }))
    assert (second = Hostgroup.create(:name => "SecondA", :parent_id => top.id, :group_parameters_attributes => {
      pid += 1 =>{"name"=>"topA", "value"=>"2", :nested => ""},
      pid += 1 =>{"name"=>"secondA", "value"=>"2", :nested => ""}}))

    assert second.parameters.include? "topA"
    assert_equal "2", second.parameters["topA"]
    assert second.parameters.include? "topB"
    assert_equal "1", second.parameters["topB"]
    assert second.parameters.include? "topC"
    assert_equal "1", second.parameters["topC"]
    assert second.parameters.include? "secondA"
    assert_equal "2", second.parameters["secondA"]

    assert (third = Hostgroup.create(:name => "ThirdA", :parent_id => second.id, :group_parameters_attributes => {
      pid += 1 =>{"name"=>"topB", "value"=>"3", :nested => ""},
      pid += 1 =>{"name"=>"topA", "value"=>"3", :nested => ""}}))

    assert third.parameters.include? "topA"
    assert_equal "3", third.parameters["topA"]
    assert third.parameters.include? "topB"
    assert_equal "3", third.parameters["topB"]
    assert third.parameters.include? "topC"
    assert_equal "1", third.parameters["topC"]
    assert third.parameters.include? "secondA"
    assert_equal "2", third.parameters["secondA"]
  end

  test "should inherit parent classes" do
    child, top = nil
    as_admin do
      top = Hostgroup.create!(:name => "topA")
      top.puppetclasses << Puppetclass.first
      child = Hostgroup.create!(:name => "secondB", :parent_id => top.id)
      child.puppetclasses << Puppetclass.last
    end

    assert_equal [Puppetclass.first, Puppetclass.last].sort, child.classes.sort
  end

  test "blocks deletion of hosts with children" do
    top = Hostgroup.create(:name => "topA")
    second = Hostgroup.create(:name => "secondB", :parent_id => top.id)

    assert top.has_children?
    assert_raise Ancestry::AncestryException do
      top.destroy
    end
  end

  test "changing name of hostgroup updates other hostgroup labels" do
    #setup - add parent to hostgroup :common (not in fixtures, since no field parent_id)
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!

    # change name of parent
    assert parent_hostgroup.update_attributes(:name => "new_common")
    # check if hostgroup(:db) label changed
    hostgroup.reload
    assert_equal "new_common/db", hostgroup.label
  end

  test "deleting a hostgroup with children does not change labels" do
    #setup - get label "common/db"
    hostgroup = hostgroups(:db)
    parent_hostgroup = hostgroups(:common)
    hostgroup.parent_id = parent_hostgroup.id
    assert hostgroup.save!
    hostgroup.reload
    assert_equal "Common/db", hostgroup.label

    #attempt to destroy parent hostgroup
    begin
    assert_not parent_hostgroup.destroy
    rescue Ancestry::AncestryException
    end
    # check if hostgroup(:db) label remains the same
    hostgroup.reload
    assert_equal "Common/db", hostgroup.label
  end

  test "should find associated lookup_values" do
    assert_equal [lookup_values(:hostgroupcommon), lookup_values(:four)], hostgroups(:common).lookup_values.sort
  end

  test "should find associated lookup_values with unsafe SQL name" do
    hostgroup = hostgroups(:common)
    hostgroup.name = "Robert';"
    hostgroup.save!
    lv = lookup_values(:four)
    lv.match = "hostgroup=#{hostgroup.name}"
    lv.save!
    assert_equal [lookup_values(:hostgroupcommon), lookup_values(:four)], hostgroup.lookup_values.sort
  end

  # test NestedAncestryCommon methods generate by class method nested_attribute_for
  test "respond to nested_attribute_for methods" do
    hostgroup = hostgroups(:common)
    [:compute_profile_id, :environment_id, :domain_id, :puppet_proxy_id, :puppet_ca_proxy_id,
     :operatingsystem_id, :architecture_id, :medium_id, :ptable_id, :subnet_id].each do |field|
      assert hostgroup.respond_to?("inherited_#{field}")
    end
  end

  test "inherited id value equals field id value if no ancestry" do
    hostgroup = hostgroups(:common)
    [:compute_profile_id, :environment_id, :domain_id, :puppet_proxy_id, :puppet_ca_proxy_id,
     :operatingsystem_id, :architecture_id, :medium_id, :ptable_id, :subnet_id].each do |field|
      assert_equal hostgroup.send(field), hostgroup.send("inherited_#{field}")
    end
  end

  test "inherited id value equals parent's field id value if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    # environment_id is not included in the array below since child value is not null
    [:compute_profile_id, :domain_id, :puppet_proxy_id, :puppet_ca_proxy_id,
     :operatingsystem_id, :architecture_id, :medium_id, :ptable_id, :subnet_id].each do |field|
      assert_equal parent.send(field), child.send("inherited_#{field}")
    end
  end

  test "inherited id value does not inherit parent's field id value if the child's value is not null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    # only environment_id is overriden in inherited fixture
    refute_equal parent.environment_id, child.inherited_environment_id
    assert_equal child.environment_id, child.inherited_environment_id
  end

  test "inherited object equals parent object if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    # methods below do not include _id
    # environment is not included in the array below since child value is not null
    [:compute_profile, :domain, :puppet_proxy, :puppet_ca_proxy,
     :operatingsystem, :architecture, :medium, :ptable, :subnet].each do |field|
      assert_equal parent.send(field), child.send(field)
    end
  end

  test "inherited object does not inherit parent object if the child's value is null" do
    child = hostgroups(:inherited)
    parent = hostgroups(:parent)
    # only environment_id is overriden in inherited fixture
    refute_equal parent.environment, child.environment
    assert_equal environments(:production), child.environment
  end

end
