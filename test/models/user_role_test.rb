require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
  end

  test "type detection" do
    user_role = FactoryBot.create :user_user_role
    assert user_role.user_role?
    usergroup_role = FactoryBot.create :user_group_user_role
    assert usergroup_role.user_group_role?
  end

  test "cache user roles" do
    user = FactoryBot.create :user
    FactoryBot.create :user_user_role, :owner => user
    cached_user_roles = user.cached_user_roles.map(&:role)

    user.roles.each do |role|
      assert_includes cached_user_roles, role
    end
  end

  test "cache usergroup roles" do
    user_role = setup_admins_scenario

    users = @semiadmin_users + [@admin_user] + [@superadmin_user]
    users.each do |user|
      cached_user_roles = user.cached_user_roles
      assert_includes cached_user_roles.map(&:role), user_role.role
      assert_includes cached_user_roles.map(&:user_role), user_role
    end
  end

  test "update role of usergroup role" do
    new_role = FactoryBot.create :role
    user_role = setup_admins_scenario
    user_role.role = new_role
    user_role.save

    users = @semiadmin_users + [@admin_user] + [@superadmin_user]
    users.each do |user|
      assert_includes user.cached_user_roles.map(&:role), new_role
    end
  end

  test "update owner of usergroup role" do
    user_role = setup_admins_scenario
    user_role.owner = @admins
    user_role.save

    users = [@admin_user, @superadmin_user]
    users.each do |user|
      assert_includes user.cached_user_roles.map(&:role), user_role.role
    end

    users = @semiadmin_users
    users.each do |user|
      assert_not_empty user.cached_user_roles
      assert_equal user.cached_user_roles.length, 1
    end
  end

  def setup_admins_scenario
    @semiadmins  = FactoryBot.create :usergroup
    @admins      = FactoryBot.create :usergroup
    @superadmins = FactoryBot.create :usergroup

    @semiadmins.usergroups = [@admins]
    @admins.usergroups     = [@superadmins]

    @semiadmin_users = [FactoryBot.create(:user, :login => 'ur_semiadmin1'),
                        FactoryBot.create(:user, :login => 'ur_semiadmin2')]
    @admin_user      = FactoryBot.create(:user, :login => 'ur_admin1')
    @superadmin_user = FactoryBot.create(:user, :login => 'ur_superadmin1')

    @semiadmins.users += @semiadmin_users
    @admins.users      = [@admin_user]
    @superadmins.users = [@superadmin_user]

    FactoryBot.create :user_group_user_role, :owner => @semiadmins
  end
end
