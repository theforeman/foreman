require 'test_helper'

class GroupParameterTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end
  test "should have a reference_id" do
    group_parameter = GroupParameter.new
    assert !group_parameter.save

    group_parameter.name = "valid"
    group_parameter.value = "valid"
    hostgroup = Hostgroup.find_or_create_by(:name => "valid")
    group_parameter.reference_id = hostgroup.id
    assert group_parameter.save
  end

  test "duplicate names cannot exist in a hostgroup" do
    GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => hostgroups(:common).id
    parameter2 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => hostgroups(:common).id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist in different hostgroups" do
    GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => hostgroups(:common).id
    parameter2 = GroupParameter.create :name => "some_parameter", :value => "value", :reference_id => hostgroups(:db).id
    assert parameter2.valid?
  end
end

