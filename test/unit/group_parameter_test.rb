require 'test_helper'

class GroupParameterTest < ActiveSupport::TestCase
  test "should have a hostgroup_id" do
    group_parameter = GroupParameter.new
    assert !group_parameter.save

    group_parameter.name = "valid"
    group_parameter.value = "valid"
    hostgroup = Hostgroup.find_or_create_by_name("valid")
    group_parameter.hostgroup_id = hostgroup.id
    assert group_parameter.save
  end
end

