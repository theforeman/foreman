require 'test_helper'

class InflectionTest < ActiveSupport::TestCase
  test "puppetclass.singularize should equal puppetclass" do
    assert_equal "puppetclass", "puppetclass".singularize
  end

  test "host_class.singularize should equal host_class" do
    assert_equal "host_class", "host_class".singularize
    assert_equal "HostClass", "HostClass".singularize
  end

  test "hostgroup_class.singularize should equal hostgroup_class" do
    assert_equal "hostgroup_class", "hostgroup_class".singularize
    assert_equal "HostgroupClass", "HostgroupClass".singularize
  end
end
