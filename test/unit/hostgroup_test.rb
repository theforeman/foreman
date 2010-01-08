require 'test_helper'

class HostgroupTest < ActiveSupport::TestCase
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
end
