require 'test_helper'

class GroupParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "should have a reference_id" do
    group_parameter = GroupParameter.new
    assert !group_parameter.save

    group_parameter.name = "valid"
    group_parameter.value = "valid"
    hostgroup = Hostgroup.find_or_create_by_name("valid")
    group_parameter.reference_id = hostgroup.id
    assert group_parameter.save
  end

  test "duplicate names cannot exist in a hostgroup" do
    parameter1 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => Hostgroup.first.id
    parameter2 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => Hostgroup.first.id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist in different hostgroups" do
    parameter1 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => Hostgroup.first.id
    parameter2 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => Hostgroup.last.id
    assert parameter2.valid?
  end

  def setup_user operation, type = "hostgroups"
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_#{type}"
      role.permissions = ["#{operation}_#{type}".to_sym]
      @one.roles = [role]
      @one.hostgroups = []
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create when permitted" do
    setup_user "create", "params"
    as_admin do
      @one.hostgroups = [hostgroups(:common)]
    end
    record =  GroupParameter.create :name => "dummy", :value => "value", :reference_id => hostgroups(:common).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with create permissions should not be able to create when not permitted" do
    setup_user "create"
    as_admin do
      @one.hostgroups = [hostgroups(:common)]
    end
    record =  GroupParameter.create :name => "dummy", :value => "value", :reference_id => hostgroups(:unusual).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with create permissions should be able to create when unconstrained" do
    setup_user "create", "params"
    as_admin do
      @one.hostgroups = []
    end
    record =  GroupParameter.create :name => "dummy", :value => "value", :reference_id => hostgroups(:common).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create when not permitted" do
    setup_user "view"
    record =  GroupParameter.create :name => "dummy", :value => "value", :reference_id => hostgroups(:common).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy", "params"
    record =  GroupParameter.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  GroupParameter.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit", "params"
    record      =  GroupParameter.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  GroupParameter.first
    record.name = "renamed"
    assert !record.save
  end
end

