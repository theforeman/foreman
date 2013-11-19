require 'test_helper'

class SystemClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
  end

  test "non-admin user with permission :edit_classes can add puppetclass to system" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('SystemClass.count') do
      system = systems(:one)
      puppetclass = puppetclasses(:two)
      assert System.my_systems.include?(system)
      assert system.update_attributes :puppetclass_ids => (system.puppetclass_ids + Array.wrap(puppetclass.id))
    end
  end

  test "non-admin user without permission :edit_classes cannot add puppetclass to system" do
    # do not assign any role to Current.user
    assert_difference('SystemClass.count', 0) do
      system = systems(:one)
      puppetclass = puppetclasses(:two)
      assert System.my_systems.include?(system)
      assert_raises(ActiveRecord::RecordNotSaved) do
        refute system.update_attributes :puppetclass_ids => (system.puppetclass_ids + Array.wrap(puppetclass.id))
      end
    end
  end

  test "non-admin user with permission :edit_classes can remove puppetclass from system" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('SystemClass.count', -1) do
      system = systems(:one)
      assert System.my_systems.include?(system)
      assert system.update_attributes :puppetclass_ids => []
    end
  end

  test "non-admin user without permission :edit_classes cannot remove puppetclass from system" do
    # do not assign any role to Current.user
    assert_difference('SystemClass.count', 0) do
      system = systems(:one)
      puppetclass = puppetclasses(:two)
      assert System.my_systems.include?(system)
      refute system.update_attributes :puppetclass_ids => []
    end
  end

end
