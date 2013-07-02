require 'test_helper'

class HostGroupsHelperTest < ActionView::TestCase
  include HostsAndHostgroupsHelper
  include ApplicationHelper

  test "should have the full string of the parent class if the child is a substring" do
    test_group = Hostgroup.create(:name => "test/st")
    assert_match /test\/st/, hostgroup_name(test_group)
    refute_match /te\/st/, hostgroup_name(test_group)
  end
end
