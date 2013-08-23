require 'test_helper'

class HostClassTest < ActiveSupport::TestCase

  setup do
    disable_orchestration
    User.current = User.find_by_login "one"
    # puppetclasses(:two) needs to be in production environment
    EnvironmentClass.create(:puppetclass_id => puppetclasses(:two).id, :environment_id => environments(:production).id )
  end

  test "non-admin user with permission :edit_classes can add puppetclass to host" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('HostClass.count') do
      host = hosts(:one)
      puppetclass = puppetclasses(:two)
      assert Host.my_hosts.include?(host)
      assert host.update_attributes :puppetclass_ids => (host.puppetclass_ids + Array.wrap(puppetclass.id))
    end
  end

  test "non-admin user without permission :edit_classes cannot add puppetclass to host" do
    # do not assign any role to Current.user
    assert_difference('HostClass.count', 0) do
      host = hosts(:one)
      puppetclass = puppetclasses(:two)
      assert Host.my_hosts.include?(host)
      assert_raises(ActiveRecord::RecordNotSaved) do
        refute host.update_attributes :puppetclass_ids => (host.puppetclass_ids + Array.wrap(puppetclass.id))
      end
    end
  end

  test "non-admin user with permission :edit_classes can remove puppetclass from host" do
    # role "manager" has permission :edit_classes
    User.current.roles << [roles(:manager)]
    assert_difference('HostClass.count', -1) do
      host = hosts(:one)
      assert Host.my_hosts.include?(host)
      assert host.update_attributes :puppetclass_ids => []
    end
  end

  test "non-admin user without permission :edit_classes cannot remove puppetclass from host" do
    # do not assign any role to Current.user
    assert_difference('HostClass.count', 0) do
      host = hosts(:one)
      puppetclass = puppetclasses(:two)
      assert Host.my_hosts.include?(host)
      refute host.update_attributes :puppetclass_ids => []
    end
  end

end
