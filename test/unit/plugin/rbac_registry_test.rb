require 'test_helper'

class RbacRegistryTest < ActiveSupport::TestCase
  def test_registered_roles
    edit_hosts = "Edit hosts"
    destroy_hosts = "Destroy hosts"
    role_1 = Role.find_by :name => edit_hosts
    role_2 = Role.find_by :name => destroy_hosts
    registry = Foreman::Plugin::RbacRegistry.new
    registry.role_ids = [role_1.id, role_2.id]
    result = registry.registered_roles
    assert_equal 2, result.count
    assert result.map(&:name).include? edit_hosts
    assert result.map(&:name).include? destroy_hosts
  end

  def test_registered_permissions
    registry = Foreman::Plugin::RbacRegistry.new
    registry.permission_names = [:view_hosts, :create_hosts]
    result = registry.registered_permissions
    assert_equal 2, result.count
    assert result.map(&:name).include? "view_hosts"
    assert result.map(&:name).include? "create_hosts"
  end

  def test_permissions
    registry = Foreman::Plugin::RbacRegistry.new
    registry.permission_names = [:view_hosts]
    result = registry.permissions
    assert_equal "Host", result[:view_hosts][:resource_type]
  end
end
