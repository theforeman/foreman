require 'test_helper'

class HostgroupClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
    # add hostgroups(:common) to users(:one) hostgroups
    UserHostgroup.create(:user_id => User.current.id, :hostgroup_id => hostgroups(:common).id)
  end

  test 'when creating a new hostgroup class object, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        HostgroupClass.create! :puppetclass => puppetclasses(:one), :hostgroup => hostgroups(:db)
      end
    end
  end

  test "non-admin user with permission :edit_hostgroups can add puppetclass to hostgroup" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('HostgroupClass.count') do
      hostgroup = hostgroups(:common)
      puppetclass = puppetclasses(:two)
      assert Hostgroup.my_groups.include?(hostgroup)
      assert hostgroup.update_attributes :puppetclass_ids => (hostgroup.puppetclass_ids + Array.wrap(puppetclass.id))
    end
  end

  test "non-admin user without permission :edit_hostgroups cannot add puppetclass to hostgroup" do
    # do not assign any role to Current.user
    assert_difference('HostgroupClass.count', 0) do
      hostgroup = hostgroups(:common)
      puppetclass = puppetclasses(:two)
      assert Hostgroup.my_groups.include?(hostgroup)
      assert_raises(ActiveRecord::RecordNotSaved) do
        refute hostgroup.update_attributes :puppetclass_ids => (hostgroup.puppetclass_ids + Array.wrap(puppetclass.id))
      end
    end
  end

  test "non-admin user with permission :edit_hostgroups can remove puppetclass from hostgroup" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('HostgroupClass.count', -1) do
      hostgroup = hostgroups(:common)
      assert Hostgroup.my_groups.include?(hostgroup)
      assert hostgroup.update_attributes :puppetclass_ids => []
    end
  end

  test "non-admin user without permission :edit_hostgroups cannot remove puppetclass from hostgroup" do
    # do not assign any role to Current.user
    assert_difference('HostgroupClass.count', 0) do
      hostgroup = hostgroups(:common)
      puppetclass = puppetclasses(:two)
      assert Hostgroup.my_groups.include?(hostgroup)
      refute hostgroup.update_attributes :puppetclass_ids => []
    end
  end
end
