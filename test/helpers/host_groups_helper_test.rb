require 'test_helper'

class HostGroupsHelperTest < ActionView::TestCase
  include PuppetRelatedHelper
  include HostsAndHostgroupsHelper
  include ApplicationHelper
  include HostsHelper
  include AuthorizeHelper
  include ::FormHelper

  test "should have the full string of the parent class if the child is a substring" do
    test_group = Hostgroup.create(:name => "test/st")
    stubs(:url_for).returns('/some/url')
    assert_match /test\/st/, label_with_link(test_group)
    refute_match /te\/st/, label_with_link(test_group)
  end

  test "visible_compute_profiles should only show profiles users is authorized to see" do
    role = FactoryBot.create(:role)
    cp = ComputeProfile.first
    FactoryBot.create(:filter, :role => role, :permissions => [permissions(:view_compute_profiles)], :search => "name = #{cp.name}")
    user = FactoryBot.create(:user, :roles => [role])
    host = FactoryBot.create(:host)
    as_user(user) do
      assert_equal [cp], visible_compute_profiles(host)
    end

    # allow seeing current cp even if it isn't authorized (to prevent incorrect changes)
    host.update_attribute(:compute_profile, ComputeProfile.second)
    as_user(user) do
      assert_equal [cp, ComputeProfile.second], visible_compute_profiles(host)
    end
  end
end
