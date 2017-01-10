require 'test_helper'

class SeedHelperTest < ActiveSupport::TestCase
  test "should create locked role" do
    role_name = "Test role"
    permissions_names = [:view_hosts, :destroy_hosts]
    refute Role.find_by(:name => role_name)
    SeedHelper.create_role role_name, permissions_names, 0
    role = Role.find_by(:name => role_name)
    assert role
    assert_equal permissions_names.sort, role.permissions.pluck(:name).sort.map(&:to_sym)
  end

  test "should recognize object was modified" do
    medium = Medium.last
    medium_name = medium.name
    refute SeedHelper.audit_modified?(Medium, medium.name)
    medium.update(:name => "renamed medium")
    assert SeedHelper.audit_modified?(Medium, medium_name)
  end
end
