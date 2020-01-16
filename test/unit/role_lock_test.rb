require 'test_helper'

class RoleLockTest < ActiveSupport::TestCase
  setup do
    @role_lock = Foreman::Plugin::RoleLock.new('foreman_test')
    @permissions = [:view_hosts]
  end

  def find_role(name)
    Role.find_by :name => name
  end

  test "should generate new name without num" do
    prefix = "Customized"
    name = "Manager"
    assert_equal "#{prefix} #{name}", @role_lock.generate_name(prefix, name)
  end

  test "should generate new name with num" do
    prefix = "Random"
    name = "Viewer"
    num = 2
    assert_equal "#{prefix} #{name} #{num}", @role_lock.generate_name(prefix, name, num)
  end

  test "should rename role with a free name" do
    role = roles(:create_hosts)
    original_name = role.name
    prefix = "Customized"
    new_name = "#{prefix} #{original_name} 1"
    taken_name = "#{prefix} #{original_name}"
    FactoryBot.create(:role, :name => taken_name)
    refute find_role(new_name)
    @role_lock.rename_existing role, original_name
    assert find_role(new_name)
  end

  test "should rename existing role" do
    role = roles(:create_hosts)
    original_name = role.name
    new_name = "Customized #{original_name}"
    refute find_role(new_name)
    @role_lock.rename_existing role, original_name
    assert find_role(new_name)
  end

  test "should create plugin role" do
    name = "Test Manager"
    refute find_role(name)
    @role_lock.create_plugin_role name, @permissions, 'some description'
    role = find_role(name)
    assert role
    assert_equal @permissions, role.permissions.pluck(:name).map(&:to_sym)
    assert_equal @role_lock.plugin_id, role.origin
    assert_equal 'some description', role.description
    assert role.locked?
  end

  test "should process existing role with changed permissions list and rename it" do
    role = roles(:create_hosts)
    role.update_attribute :origin, nil
    original_name = role.name
    original_id = role.id
    @role_lock.process_role original_name, @permissions
    renamed_role = find_role("Customized Create hosts")
    assert renamed_role
    assert_equal original_id, renamed_role.id
    new_role = find_role(original_name)
    assert new_role
    refute_equal renamed_role, new_role
  end

  test "should process existing role with origin and new permissions" do
    role = roles(:manage_hosts)
    perms = [:view_architectures, :create_hosts, :edit_hosts, :view_hosts, :destroy_hosts]
    role.update_attribute :origin, 'foreman_plugin'
    original_name = role.name
    @role_lock.process_role(original_name, perms)
    refute find_role("Customized CRUD hosts")
    original_role = find_role(original_name)
    assert_equal original_role.id, role.id
    assert original_role.permission_diff(perms).empty?
  end

  test "should process existing role with origin and removed permissions" do
    role = roles(:manage_hosts)
    perms = [:create_hosts, :view_hosts]
    role.update_attribute :origin, 'foreman_plugin'
    original_name = role.name
    @role_lock.process_role(original_name, perms)
    refute find_role("Customized CRUD hosts")
    original_role = find_role(original_name)
    assert_equal original_role.id, role.id
    assert original_role.permission_diff(perms).empty?
  end

  test "should process existing role with unchanged permissions list" do
    role = roles(:create_hosts)
    original_name = role.name
    original_id = role.id
    refute role.locked?
    role = @role_lock.process_role original_name, role.permissions.pluck(:name).map(&:to_sym)
    updated_original = find_role(original_name)
    assert_equal original_id, updated_original.id
    assert_equal original_name, updated_original.name
    assert @role_lock.plugin_id, updated_original.origin
    assert role.locked?
  end

  test "should process missing role" do
    role_name = "Test Manager"
    refute find_role(role_name)
    @role_lock.process_role role_name, [:view_hosts]
    new_role = find_role(role_name)
    assert new_role
    assert new_role.locked?
  end

  test "should register role" do
    name = "Test Manager"
    registry = Foreman::Plugin::RbacRegistry.new
    assert_empty registry.role_ids
    @role_lock.register_role name, @permissions, registry
    refute_empty registry.role_ids
    assert_equal Role.find(registry.role_ids.first).name, name
  end

  test "should update description of register role" do
    name = "Test Manager"
    registry = Foreman::Plugin::RbacRegistry.new
    assert_empty registry.role_ids
    @role_lock.register_role name, @permissions, registry
    role = Role.find(registry.role_ids.first)
    assert_equal role.name, name
    assert_empty role.description

    @role_lock.register_role name, @permissions, registry, 'new description'
    role = Role.find(registry.role_ids.first)
    assert_equal 'new description', role.description
  end
end
