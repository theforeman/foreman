require 'test_helper'

class GroupParameterTest < ActiveSupport::TestCase
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
    parameter1 = GroupParameter.create :name => "some parameter", :value => "value", :reference_id => Hostgroup.first.id
    parameter2 = GroupParameter.create :name => "some parameter", :value => "value", :reference_id => Hostgroup.first.id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist in different hostgroups" do
    parameter1 = GroupParameter.create :name => "some parameter", :value => "value", :reference_id => Hostgroup.first.id
    parameter2 = GroupParameter.create :name => "some parameter", :value => "value", :reference_id => Hostgroup.last.id
    assert parameter2.valid?
  end
end

