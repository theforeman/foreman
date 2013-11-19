require 'test_helper'

class SystemGroupClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
    # add system_groups(:common) to users(:one) system_groups
    UserSystemGroup.create(:user_id => User.current.id, :system_group_id => system_groups(:common).id)
  end

  test 'when creating a new system_group class object, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        SystemGroupClass.create! :puppetclass => puppetclasses(:one), :system_group => system_groups(:db)
      end
    end
  end

  test "non-admin user with permission :edit_system_groups can add puppetclass to system_group" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('SystemGroupClass.count') do
      system_group = system_groups(:common)
      puppetclass = puppetclasses(:two)
      assert SystemGroup.my_groups.include?(system_group)
      assert system_group.update_attributes :puppetclass_ids => (system_group.puppetclass_ids + Array.wrap(puppetclass.id))
    end
  end

  test "non-admin user without permission :edit_system_groups cannot add puppetclass to system_group" do
    # do not assign any role to Current.user
    assert_difference('SystemGroupClass.count', 0) do
      system_group = system_groups(:common)
      puppetclass = puppetclasses(:two)
      assert SystemGroup.my_groups.include?(system_group)
      assert_raises(ActiveRecord::RecordNotSaved) do
        refute system_group.update_attributes :puppetclass_ids => (system_group.puppetclass_ids + Array.wrap(puppetclass.id))
      end
    end
  end

  test "non-admin user with permission :edit_system_groups can remove puppetclass from system_group" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('SystemGroupClass.count', -1) do
      system_group = system_groups(:common)
      assert SystemGroup.my_groups.include?(system_group)
      assert system_group.update_attributes :puppetclass_ids => []
    end
  end

  test "non-admin user without permission :edit_system_groups cannot remove puppetclass from system_group" do
    # do not assign any role to Current.user
    assert_difference('SystemGroupClass.count', 0) do
      system_group = system_groups(:common)
      puppetclass = puppetclasses(:two)
      assert SystemGroup.my_groups.include?(system_group)
      refute system_group.update_attributes :puppetclass_ids => []
    end
  end
end
