require 'test_helper'

class SeedHelperTest < ActiveSupport::TestCase
  test "should create locked role" do
    role_name = "Test role"
    permissions_names = [:view_hosts, :destroy_hosts]
    refute Role.find_by(:name => role_name)
    SeedHelper.create_role role_name, {:permissions => permissions_names}, 0
    role = Role.find_by(:name => role_name)
    assert role
    assert_equal permissions_names.sort, role.permissions.pluck(:name).sort.map(&:to_sym)
  end

  test "should update a description for a role" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => []}, 0
    role = Role.find_by(:name => role_name)
    refute_equal 'new description', role.description
    SeedHelper.create_role role_name, {:permissions => [], :description => 'new description'}, 0
    assert_equal 'new description', role.reload.description
  end

  test "should add new permissions to existing roles" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => [:view_domains, :edit_domains]}, 0
    role = Role.find_by(:name => role_name)

    SeedHelper.create_role role_name, {:permissions => [:edit_domains, :create_domains]}, 0
    permissions = role.permissions.pluck(:name)
    # create new permissions
    assert_includes permissions, 'create_domains'
    # keeps existing permissions
    assert_includes permissions, 'edit_domains'
    # drops additional permissions
    refute_includes permissions, 'view_domains'
  end

  test "should not try add new permissions to existing roles if it's explicitly disabled, the permission might not exist e.g. while in migration" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => [:view_domains, :edit_domains]}, 0
    role = Role.find_by(:name => role_name)

    SeedHelper.create_role role_name, {:permissions => [:edit_domains, :create_domains], :update_permissions => false}, 0
    permissions = role.permissions.pluck(:name)
    # does not create new permission
    refute_includes permissions, 'create_domains'
    # keeps existing permissions
    assert_includes permissions, 'edit_domains'
    assert_includes permissions, 'view_domains'
  end

  test "should recognize object was modified" do
    medium = Medium.last
    medium_name = medium.name
    refute SeedHelper.audit_modified?(Medium, medium.name)
    medium.update(:name => "renamed medium")
    assert SeedHelper.audit_modified?(Medium, medium_name)
  end
end
