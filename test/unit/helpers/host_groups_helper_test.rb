require 'test_helper'

class HostGroupsHelperTest < ActionView::TestCase
  include HostsAndHostgroupsHelper
  include ApplicationHelper

  test "should have the full string of the parent class if the child is a substring" do
    test_group = Hostgroup.create(:name => "test/st")
    stubs(:url_for).returns('/some/url')
    assert_match /test\/st/, label_with_link(test_group)
    refute_match /te\/st/, label_with_link(test_group)
  end
end
