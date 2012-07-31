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
    assert !host_group.name.strip.squeeze(" ").empty?
    assert !host_group.save

    host_group.name.strip!.squeeze!(" ")
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
    record =  Hostgroup.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Hostgroup.first
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
      record.hosts = []
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
   assert (top = Hostgroup.create(:name => "topA", "puppetclass_ids"=>[Puppetclass.first.id]))
   assert (second = Hostgroup.create(:name => "secondB", :parent_id => top.id, "puppetclass_ids"=>[Puppetclass.last.id]))

   assert_equal [Puppetclass.first, Puppetclass.last].sort, second.classes.sort
  end

  test "should remove relationships if deleting a parent hostgroup" do
   assert (top = Hostgroup.create(:name => "topA"))
   assert (second = Hostgroup.create(:name => "secondB", :parent_id => top.id))

   assert top.has_children?
   assert !second.is_root?
   assert top.destroy
   assert Hostgroup.find(second.id).is_root?
  end

  test "vm_defaults_should_be_a_hash" do
    assert_kind_of Hash, hostgroups(:common).vm_defaults
  end

  test "hostgroup_should_have_vm_attributes" do
    assert !Vm::PROPERTIES.empty?
    hg = hostgroups(:common)
    Vm::PROPERTIES.each do |attr|
      assert_respond_to hg, attr
    end
  end

  test "vm attributes should be serialized" do
    hg = hostgroups(:common)
    hg.memory = 1024
    hg.interface = "br0"
    assert hg.save
    assert_equal 1024, Hostgroup.find(hg.id).memory
    assert_equal "br0", Hostgroup.find(hg.id).interface
  end

end
