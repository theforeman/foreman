require 'test_helper'

class SystemGroupTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "name can't be blank" do
    system_group = SystemGroup.new :name => "  "
    assert system_group.name.strip.empty?
    assert !system_group.save
  end

  test "name can't contain trailing white spaces" do
    system_group = SystemGroup.new :name => " all    systems in the     world    "
    assert !system_group.name.squeeze(" ").empty?
    assert !system_group.save

    system_group.name.squeeze!(" ")
    assert system_group.save
  end

  test "name must be unique" do
    system_group = SystemGroup.new :name => "some systems"
    assert system_group.save

    other_system_group = SystemGroup.new :name => "some systems"
    assert !other_system_group.save
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_system_group"
      role.permissions = ["#{operation}_system_groups".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  SystemGroup.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  SystemGroup.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  SystemGroup.first
    as_admin do
      record.systems.destroy_all
      record.system_group_classes.destroy_all
      assert record.destroy
    end
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  SystemGroup.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  SystemGroup.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  SystemGroup.first
    record.name = "renamed"
    as_admin do
      record.systems.destroy_all
    end
    assert !record.save
    assert record.valid?
  end

  test "should be able to nest a group parameters" do
    # creates a 3 level hirecy, each one with his own parameters
    # and overrides.
    pid = Time.now.to_i
    assert (top = SystemGroup.create(:name => "topA", :group_parameters_attributes => {
      pid += 1=>{"name"=>"topA", "value"=>"1", :nested => ""},
      pid += 1=>{"name"=>"topB", "value"=>"1", :nested => ""},
      pid += 1=>{"name"=>"topC", "value"=>"1", :nested => ""},
    }))
    assert (second = SystemGroup.create(:name => "SecondA", :parent_id => top.id, :group_parameters_attributes => {
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

    assert (third = SystemGroup.create(:name => "ThirdA", :parent_id => second.id, :group_parameters_attributes => {
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
      top = SystemGroup.create!(:name => "topA")
      top.puppetclasses << Puppetclass.first
      child = SystemGroup.create!(:name => "secondB", :parent_id => top.id)
      child.puppetclasses << Puppetclass.last
    end

    assert_equal [Puppetclass.first, Puppetclass.last].sort, child.classes.sort
  end

  test "should remove relationships if deleting a parent system_group" do
   assert (top = SystemGroup.create(:name => "topA"))
   assert (second = SystemGroup.create(:name => "secondB", :parent_id => top.id))

   assert top.has_children?
   assert !second.is_root?
   assert top.destroy
   assert SystemGroup.find(second.id).is_root?
  end

  test "changing name of system_group updates other system_group labels" do
    #setup - add parent to system_group :common (not in fixtures, since no field parent_id)
    system_group = system_groups(:db)
    parent_system_group = system_groups(:common)
    system_group.parent_id = parent_system_group.id
    assert system_group.save!

    # change name of parent
    assert parent_system_group.update_attributes(:name => "new_common")
    # check if system_group(:db) label changed
    system_group.reload
    assert_equal "new_common/db", system_group.label
  end

  test "deleting a system_group updates other system_group labels" do
    #setup - get label "common/db"
    system_group = system_groups(:db)
    parent_system_group = system_groups(:common)
    system_group.parent_id = parent_system_group.id
    assert system_group.save!
    system_group.reload
    assert_equal "Common/db", system_group.label

    #destory parent system_group
    assert parent_system_group.destroy
    # check if system_group(:db) label changed
    system_group.reload
    assert_equal "db", system_group.label
  end

  test "should find associated lookup_values" do
    assert_equal [lookup_values(:system_groupcommon), lookup_values(:four)], system_groups(:common).lookup_values.sort
  end

  test "should find associated lookup_values with unsafe SQL name" do
    system_group = system_groups(:common)
    system_group.name = "Robert';"
    system_group.save!
    lv = lookup_values(:four)
    lv.match = "system_group=#{system_group.name}"
    lv.save!
    assert_equal [lookup_values(:four)], system_group.lookup_values
  end

end
