require 'test_helper'

class RbacRegistryTest < ActiveSupport::TestCase
  def test_registered_roles
    edit_hosts = "Edit hosts"
    destroy_hosts = "Destroy hosts"
    role_1 = Role.find_by :name => edit_hosts
    role_2 = Role.find_by :name => destroy_hosts
    registry = Foreman::Plugin::RbacRegistry.new(:test)
    registry.role_ids = [role_1.id, role_2.id]
    result = registry.registered_roles
    assert_equal 2, result.count
    assert result.map(&:name).include? edit_hosts
    assert result.map(&:name).include? destroy_hosts
  end

  def test_registered_permissions
    registry = Foreman::Plugin::RbacRegistry.new(:test)
    registry.register :view_hosts, :resource_type => 'Host'
    registry.register :create_hosts, :resource_type => 'Host'
    result = registry.registered_permissions
    assert_equal 2, result.count
    assert_equal 'view_hosts', result.first.first.to_s
    assert_equal 'create_hosts', result.last.first.to_s
    assert result.first.last.has_key?(:resource_type)
    assert_equal 'Host', result.first.last[:resource_type]
  end

  def test_permissions
    registry = Foreman::Plugin::RbacRegistry.new(:test)
    registry.register :view_hosts, :resource_type => 'Host'
    result = registry.permissions
    assert_equal "Host", result[:view_hosts][:resource_type]
  end
end
