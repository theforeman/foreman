require 'test_helper'

class UsergroupMemberTest < ActiveSupport::TestCase

  def setup
    User.current = User.find_by_login "admin"
  end

  test "remove membership of user in a group" do
    setup_admins_scenario
    assert_include @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    @superadmins.users.clear

    assert_not_include @superadmin_user.reload.cached_user_roles.map(&:role), @semiadmin_role
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

  test "searching for affected users memberships" do
    setup_admins_scenario

    found = @semiadmins.usergroup_members.where("member_type = 'Usergroup'").first.send :find_all_affected_memberships
    found.map! { |m| m.member }
    assert_includes found, @admin_user
    assert_includes found, @superadmin_user
    assert_not_includes found, @semiadmin_user

    found = @superadmins.usergroup_members.where("member_type = 'User'").first.send :find_all_affected_memberships
    found.map! { |m| m.member }
    assert_not_includes found, @admin_user
    assert_not_includes found, @semiadmin_user
    assert_includes found, @superadmin_user
  end

  test "remove root member in tree" do
    setup_admins_scenario

    assert_include @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_include @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    @semiadmins.usergroups.clear
    @semiadmin_user.reload; @admin_user.reload; @superadmin_user.reload

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role

    assert_not_include @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_not_include @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
  end

  test "remove leaf member in tree" do
    setup_admins_scenario

    assert_include @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_include @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_include @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role

    @admins.usergroups.clear
    @semiadmin_user.reload; @admin_user.reload; @superadmin_user.reload

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_include @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_not_include @superadmin_user.cached_user_roles.map(&:role), @admin_role
    assert_not_include @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
  end

  test "add new memership to the root" do
    setup_admins_scenario

    basic      = FactoryGirl.create :usergroup, :name => 'um_basic'
    basic_role = FactoryGirl.create :role, :name => 'um_basic_role'
    basic.roles<< basic_role
    basic.usergroups<< @semiadmins

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role
  end

  test "add new memership to the middle of chain" do
    setup_admins_scenario

    basic      = FactoryGirl.create :usergroup, :name => 'um_basic'
    basic_role = FactoryGirl.create :role, :name => 'um_basic_role'
    basic.roles<< basic_role
    basic.usergroups<< @admins

    assert_not_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role
  end

  test "add new memership to the leaf" do
    setup_admins_scenario

    basic      = FactoryGirl.create :usergroup, :name => 'um_basic'
    basic_role = FactoryGirl.create :role, :name => 'um_basic_role'
    basic.roles<< basic_role
    basic.usergroups<< @superadmins

    assert_not_includes @semiadmin_user.cached_user_roles.map(&:role), basic_role
    assert_not_includes @admin_user.cached_user_roles.map(&:role), basic_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), basic_role
  end

  test "change membership (member) in the middle of chain" do
    setup_admins_scenario

    membership = @semiadmins.usergroup_members.where(:member_id => @admins.id).first
    membership.member = @superadmins
    membership.save
    @semiadmin_user.reload; @admin_user.reload; @superadmin_user.reload

    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_not_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "change membership (hostgroup) in the middle of chain" do
    setup_admins_scenario

    membership = @admins.usergroup_members.where(:member_id => @superadmins.id).first
    membership.usergroup = @semiadmins
    membership.save
    @semiadmin_user.reload; @admin_user.reload; @superadmin_user.reload

    assert_includes @superadmin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @superadmin_user.cached_user_roles.map(&:role), @superadmin_role
    assert_not_includes @superadmin_user.cached_user_roles.map(&:role), @admin_role

    assert_includes @admin_user.cached_user_roles.map(&:role), @semiadmin_role
    assert_includes @admin_user.cached_user_roles.map(&:role), @admin_role

    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @semiadmin_role
  end

  test "user is in two joined groups, second membership is removed" do
    setup_redundant_scenario

    @admins.users = []
    assert_not_include @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in three two joined groups, middle membership is removed" do
    setup_redundant_scenario
    @superadmins = FactoryGirl.create :usergroup, :name => 'um_superadmins'
    @superadmins.usergroups = [@semiadmins]
    @superadmins.roles<< @admin_role

    @admins.users = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups, first membership is removed" do
    setup_redundant_scenario

    @semiadmins.users = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups, joining is removed" do
    setup_redundant_scenario

    @semiadmins.usergroups = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups with redundant role, second membership is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryGirl.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @admins.users = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups with redundant role, first membership is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryGirl.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @semiadmins.users = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  test "user is in two joined groups with redundant role, joining is removed" do
    setup_redundant_scenario
    @semiadmin_ur = FactoryGirl.create :user_group_user_role, :owner => @semiadmins, :role => @admin_role

    @semiadmins.usergroups = []
    assert_includes @semiadmin_user.cached_user_roles.map(&:role), @admin_role
  end

  def setup_redundant_scenario
    @semiadmins = FactoryGirl.create :usergroup, :name => 'um_semiadmins'
    @admins     = FactoryGirl.create :usergroup, :name => 'um_admins'

    @semiadmins.usergroups = [@admins]

    @semiadmin_user = FactoryGirl.create(:user, :login => 'um_semiadmin1')

    @semiadmins.users = [@semiadmin_user]
    @admins.users     = [@semiadmin_user]

    @admin_role = FactoryGirl.create(:role, :name => 'um_admin')

    @admin_ur = FactoryGirl.create :user_group_user_role, :owner => @admins, :role => @admin_role
  end

  def setup_admins_scenario
    @semiadmins  = FactoryGirl.create :usergroup, :name => 'um_semiadmins'
    @admins      = FactoryGirl.create :usergroup, :name => 'um_admins'
    @superadmins = FactoryGirl.create :usergroup, :name => 'um_superadmins'

    @semiadmins.usergroups = [@admins]
    @admins.usergroups     = [@superadmins]

    @semiadmin_user  = FactoryGirl.create(:user, :login => 'um_semiadmin1')
    @admin_user      = FactoryGirl.create(:user, :login => 'um_admin1')
    @superadmin_user = FactoryGirl.create(:user, :login => 'um_superadmin1')

    @semiadmins.users  = [@semiadmin_user]
    @admins.users      = [@admin_user]
    @superadmins.users = [@superadmin_user]

    @semiadmin_role  = FactoryGirl.create(:role, :name => 'um_semiadmin')
    @admin_role      = FactoryGirl.create(:role, :name => 'um_admin')
    @superadmin_role = FactoryGirl.create(:role, :name => 'um_superadmin')

    @semiadmin_ur  = FactoryGirl.create :user_group_user_role, :owner => @semiadmins, :role => @semiadmin_role
    @admin_ur      = FactoryGirl.create :user_group_user_role, :owner => @admins, :role => @admin_role
    @superadmin_ur = FactoryGirl.create :user_group_user_role, :owner => @superadmins, :role => @superadmin_role

    @role1 = FactoryGirl.create(:role)
    @role2 = FactoryGirl.create(:role)
    @role3 = FactoryGirl.create(:role)
    @semiadmin_user.roles<< @role1
    @admin_user.roles<< @role2
    @superadmin_user.roles<< @role3
  end
end
