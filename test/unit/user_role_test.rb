require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase

  def setup
    User.current = User.find_by_login "admin"
  end

  test "type detection" do
    user_role = FactoryGirl.create :user_user_role
    assert user_role.user_role?
    usergroup_role = FactoryGirl.create :user_group_user_role
    assert usergroup_role.user_group_role?
  end

  test "cache user roles" do
    user             = FactoryGirl.create :user
    user_role        = FactoryGirl.create :user_user_role, :owner => user
    cached_user_role = user.cached_user_roles.first

    assert_equal user_role.role, cached_user_role.role
    assert_equal user_role, cached_user_role.user_role
  end

  test "cache usergroup roles" do
    user_role = setup_admins_scenario

    users = @semiadmin_users + [@admin_user] + [@superadmin_user]
    users.each do |user|
      cached_user_role = user.cached_user_roles.first
      assert_equal user_role.role, cached_user_role.role
      assert_equal user_role, cached_user_role.user_role
    end
  end

  test "update role of usergroup role" do
    new_role = FactoryGirl.create :role
    user_role = setup_admins_scenario
    user_role.role = new_role
    user_role.save

    users = @semiadmin_users + [@admin_user] + [@superadmin_user]
    users.each  do |user|
      cached_user_role = user.cached_user_roles.first
      assert_equal new_role, cached_user_role.role
    end
  end

  test "update owner of usergroup role" do
    user_role = setup_admins_scenario
    user_role.owner = @admins
    user_role.save

    users = [@admin_user, @superadmin_user]
    users.each do |user|
      cached_user_role = user.cached_user_roles.first
      assert_equal user_role.role, cached_user_role.role
    end

    users = @semiadmin_users
    users.each do |user|
      assert_empty user.cached_user_roles
    end
  end

  def setup_admins_scenario
    @semiadmins  = FactoryGirl.create :usergroup
    @admins      = FactoryGirl.create :usergroup
    @superadmins = FactoryGirl.create :usergroup

    @semiadmins.usergroups = [@admins]
    @admins.usergroups     = [@superadmins]

    @semiadmin_users = [FactoryGirl.create(:user, :login => 'ur_semiadmin1'),
                       FactoryGirl.create(:user, :login => 'ur_semiadmin2')]
    @admin_user      = FactoryGirl.create(:user, :login => 'ur_admin1')
    @superadmin_user = FactoryGirl.create(:user, :login => 'ur_superadmin1')

    @semiadmins.users  += @semiadmin_users
    @admins.users      = [@admin_user]
    @superadmins.users = [@superadmin_user]

    FactoryGirl.create :user_group_user_role, :owner => @semiadmins
  end
end
