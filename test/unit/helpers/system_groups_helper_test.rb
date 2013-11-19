require 'test_helper'

class SystemGroupsHelperTest < ActionView::TestCase
  include SystemsAndSystemGroupsHelper
  include ApplicationHelper

  test "should have the full string of the parent class if the child is a substring" do
    test_group = SystemGroup.create(:name => "test/st")
    assert_match /test\/st/, system_group_name(test_group)
    refute_match /te\/st/, system_group_name(test_group)
  end
end
