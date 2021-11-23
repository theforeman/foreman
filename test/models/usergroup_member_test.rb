require 'test_helper'

class UsergroupMemberTest < ActiveSupport::TestCase
  test "remove membership of user in a group" do
    setup_admins_scenario
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    @superadmins.users.destroy_all

    assert_not_includes @superadmin_user.reload.cached_user_roles.map(&:role), @semiadmin_role
    cached_usergroups = @superadmin_user.cached_usergroups
    assert_not_includes cached_usergroups, @superadmins
    assert_not_includes cached_usergroups, @admins
    assert_not_includes cached_usergroups, @semiadmins
  end

  test "searching for user roles" do
    setup_admins_scenario

    found = @superadmins.usergroup_members.first.send :find_all_user_roles
    assert_includes found, @semiadmin_ur
    assert_includes found, @admin_ur
    assert_includes found, @superadmin_ur
    assert_not_includes found, @role1
    assert_not_includes found, @role2
    assert_not_includes found, @role3
  end

  test "searching for user groups" do
    setup_admins_scenario

    found = @admins.usergroup_members.first.send :find_all_usergroups
    assert_includes found, @semiadmins
    assert_includes found, @admins
    assert_not_includes found, @superadmins
  end

  test "searching for affected users memberships" do
    setup_admins_scenario

    found = @semiadmins.usergroup_members.where(member_type: 'Usergroup').first.send :find_all_affected_users
    assert_includes found, @admin_user
    assert_includes found, @superadmin_user
    assert_not_includes found, @semiadmin_user

    found = @superadmins.usergroup_members.where(member_type: 'User').first.send :find_all_affected_users
    assert_not_includes found, @admin_user
    assert_not_includes found, @semiadmin_user
    assert_includes found, @superadmin_user
  end

  test "remove root member in tree" do
    setup_admins_scenario

    assert_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    @semiadmins.usergroups.destroy_all
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role

    assert_not_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_not_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
    assert_not_includes @admin_user.cached_usergroups, @semiadmins
    assert_includes @admin_user.cached_usergroups, @admins
    assert_not_includes @superadmin_user.cached_usergroups, @semiadmins
    assert_includes @superadmin_user.cached_usergroups, @admins
    assert_includes @superadmin_user.cached_usergroups, @superadmins
  end

  test "remove leaf member in tree" do
    setup_admins_scenario

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    @admins.usergroups.destroy_all
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_not_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_not_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
    assert_includes @admin_user.cached_usergroups, @semiadmins
    assert_includes @admin_user.cached_usergroups, @admins
    assert_not_includes @superadmin_user.cached_usergroups, @semiadmins
    assert_not_includes @superadmin_user.cached_usergroups, @admins
    assert_includes @superadmin_user.cached_usergroups, @superadmins
  end

  test "add new memership to the root" do
    setup_admins_scenario

    EnsureNoCycle.any_instance.expects(:ensure).once

    basic      = FactoryBot.create :usergroup, :name => 'um_basic'
    basic_role = FactoryBot.create :role, :name => 'um_basic_role'
    basic.roles << basic_role
    basic.usergroups << @semiadmins
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role

    assert_includes @semiadmin_user.cached_usergroups, basic
    assert_includes @admin_user.cached_usergroups, basic
    assert_includes @superadmin_user.cached_usergroups, basic
  end

  test "add new memership to the middle of chain" do
    setup_admins_scenario

    EnsureNoCycle.any_instance.expects(:ensure).once

    basic      = FactoryBot.create :usergroup, :name => 'um_basic'
    basic_role = FactoryBot.create :role, :name => 'um_basic_role'
    basic.roles << basic_role
    basic.usergroups << @admins
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_not_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role

    assert_not_includes @semiadmin_user.cached_usergroups, basic
    assert_includes @admin_user.cached_usergroups, basic
    assert_includes @superadmin_user.cached_usergroups, basic
  end

  test "add new memership to the leaf" do
    setup_admins_scenario

    EnsureNoCycle.any_instance.expects(:ensure).once

    basic      = FactoryBot.create :usergroup, :name => 'um_basic'
    basic_role = FactoryBot.create :role, :name => 'um_basic_role'
    basic.roles << basic_role
    basic.usergroups << @superadmins
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_not_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_not_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role

    assert_not_includes @semiadmin_user.cached_usergroups, basic
    assert_not_includes @admin_user.cached_usergroups, basic
    assert_includes @superadmin_user.cached_usergroups, basic
  end

  test "change membership (member) in the middle of chain" do
    setup_admins_scenario

    membership = @semiadmins.usergroup_members.where(:member_id => @admins.id).first
    membership.member = @superadmins
    membership.save
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_not_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    assert_includes @superadmin_user.cached_usergroups, @semiadmins
    assert_includes @superadmin_user.cached_usergroups, @admins
    assert_includes @superadmin_user.cached_usergroups, @superadmins
    assert_not_includes @admin_user.cached_usergroups, @semiadmins
    assert_includes @admin_user.cached_usergroups, @admins
    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
  end

  test "change membership (hostgroup) in the middle of chain" do
    setup_admins_scenario

    membership = @admins.usergroup_members.where(:member_id => @superadmins.id).first
    membership.usergroup = @semiadmins
    membership.save
    [@semiadmin_user, @admin_user, @superadmin_user].map(&:reload)

    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_not_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    assert_includes @superadmin_user.cached_usergroups, @superadmins
    assert_includes @superadmin_user.cached_usergroups, @semiadmins
    assert_not_includes @superadmin_user.cached_usergroups, @admins
    assert_includes @admin_user.cached_usergroups, @semiadmins
    assert_includes @admin_user.cached_usergroups, @admins
    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
  end

  test "add new user memership" do
    EnsureNoCycle.any_instance.expects(:ensure).never

    test_user1 = FactoryBot.create(:user, :login => 'test_user1')
    basic      = FactoryBot.create :usergroup, :name => 'um_basic'
    basic_role = FactoryBot.create :role, :name => 'um_basic_role'
    basic.roles << basic_role
    basic.users << test_user1
    test_user1.reload

    assert_includes test_user1.cached_user_roles.map(&:role), basic_role
    assert_includes test_user1.cached_usergroups, basic
  end

  test "user is in two joined groups, second membership is removed" do
    setup_redundant_scenario

    @admins.users = []
    assert_not_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in three two joined groups, middle membership is removed" do
    setup_redundant_scenario
    @superadmins = FactoryBot.create :usergroup, :name => 'um_superadmins'
    @superadmins.usergroups = [@semiadmins]
    @superadmins.roles << @admin_role

    @admins.users = []
    @semiadmin_user.reload
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role

    assert_includes @semiadmin_user.cached_usergroups, @superadmins
  end

  test "diamond-with-tail usergroups, one of way is removed" do
    @a = FactoryBot.create :usergroup, :name => 'um_a'
    @b = FactoryBot.create :usergroup, :name => 'um_b'
    @c = FactoryBot.create :usergroup, :name => 'um_c'
    @d = FactoryBot.create :usergroup, :name => 'um_d'
    @e = FactoryBot.create :usergroup, :name => 'um_e'
    @a.usergroups = [@b, @c]
    @b.usergroups = [@d]
    @c.usergroups = [@d]
    @d.usergroups = [@e]

    as_admin do
      @user1 = FactoryBot.create(:user, :login => 'um_user1')
      @user2 = FactoryBot.create(:user, :login => 'um_user2')
      @user1.usergroups = [@d.reload] # @d cached #users already as []
      @user2.usergroups = [@e]
      @role = FactoryBot.create(:role, :name => 'um_role')
      @role_ur = FactoryBot.create :user_group_user_role, :owner => @a, :role => @role
    end

    assert_includes @user1.reload.cached_user_roles.map(&:role), @role
    assert_includes @user2.reload.cached_user_roles.map(&:role), @role

    assert_includes @user1.cached_usergroups, @a
    assert_includes @user1.cached_usergroups, @b
    assert_includes @user1.cached_usergroups, @c
    assert_includes @user1.cached_usergroups, @d
    assert_not_includes @user1.cached_usergroups, @e
    assert_includes @user2.cached_usergroups, @a
    assert_includes @user2.cached_usergroups, @b
    assert_includes @user2.cached_usergroups, @c
    assert_includes @user2.cached_usergroups, @d
    assert_includes @user2.cached_usergroups, @e

    @c.usergroups = []
    assert_includes @user1.reload.cached_user_roles.map(&:role), @role
    assert_includes @user2.reload.cached_user_roles.map(&:role), @role

    assert_includes @user1.cached_usergroups, @a
    assert_includes @user1.cached_usergroups, @b
    assert_not_includes @user1.cached_usergroups, @c
    assert_includes @user1.cached_usergroups, @d
    assert_not_includes @user1.cached_usergroups, @e
    assert_includes @user2.cached_usergroups, @a
    assert_includes @user2.cached_usergroups, @b
    assert_not_includes @user2.cached_usergroups, @c
    assert_includes @user2.cached_usergroups, @d
    assert_includes @user2.cached_usergroups, @e
  end

  test "user is in two joined groups, first membership is removed" do
    setup_redundant_scenario

    @semiadmins.users = []
    @semiadmin_user.reload
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
    assert_includes @semiadmin_user.cached_usergroups, @admins
  end

  test "user is in two joined groups, joining is removed" do
    setup_redundant_scenario

    @semiadmins.usergroups = []
    @semiadmin_user.reload

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
    assert_includes @semiadmin_user.cached_usergroups, @admins
  end

  test "user is in two joined groups with redundant role, second membership is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryBot.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @admins.users = []
    @semiadmin_user.reload
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @semiadmin_user.cached_usergroups, @semiadmins
  end

  test "user is in two joined groups with redundant role, first membership is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryBot.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @semiadmins.users = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups with redundant role, joining is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryBot.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @semiadmins.usergroups = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  # before destroy callback could fail, covers #25914
  test "user can be destroyed and it destroys also user group members correctly" do
    user = FactoryBot.create :user
    group = FactoryBot.create :usergroup
    group.users = [user]
    assert user.destroy
  end

  def setup_redundant_scenario
    as_admin do
      @semiadmins = FactoryBot.create :usergroup, :name => 'um_semiadmins'
      @admins     = FactoryBot.create :usergroup, :name => 'um_admins'

      @semiadmins.usergroups = [@admins]

      @semiadmin_user = FactoryBot.create(:user, :login => 'um_semiadmin1')

      @semiadmins.users = [@semiadmin_user]
      @admins.users     = [@semiadmin_user]

      @admin_role = FactoryBot.create(:role, :name => 'um_admin')

      @admin_ur = FactoryBot.create :user_group_user_role, :owner => @admins, :role => @admin_role
    end
  end

  def setup_admins_scenario
    as_admin do
      @semiadmins  = FactoryBot.create :usergroup, :name => 'um_semiadmins'
      @admins      = FactoryBot.create :usergroup, :name => 'um_admins'
      @superadmins = FactoryBot.create :usergroup, :name => 'um_superadmins'

      @semiadmins.usergroups = [@admins]
      @admins.usergroups     = [@superadmins]

      @semiadmin_user  = FactoryBot.create(:user, :login => 'um_semiadmin1')
      @admin_user      = FactoryBot.create(:user, :login => 'um_admin1')
      @superadmin_user = FactoryBot.create(:user, :login => 'um_superadmin1')

      @semiadmins.users  = [@semiadmin_user]
      @admins.users      = [@admin_user]
      @superadmins.users = [@superadmin_user]

      @semiadmin_role  = FactoryBot.create(:role, :name => 'um_semiadmin')
      @admin_role      = FactoryBot.create(:role, :name => 'um_admin')
      @superadmin_role = FactoryBot.create(:role, :name => 'um_superadmin')

      @semiadmin_ur  = FactoryBot.create :user_group_user_role, :owner => @semiadmins, :role => @semiadmin_role
      @admin_ur      = FactoryBot.create :user_group_user_role, :owner => @admins, :role => @admin_role
      @superadmin_ur = FactoryBot.create :user_group_user_role, :owner => @superadmins, :role => @superadmin_role

      @role1 = FactoryBot.create(:role)
      @role2 = FactoryBot.create(:role)
      @role3 = FactoryBot.create(:role)
      @semiadmin_user.roles << @role1
      @admin_user.roles << @role2
      @superadmin_user.roles << @role3
    end
  end
end
