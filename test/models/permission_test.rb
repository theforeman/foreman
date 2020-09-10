require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  test ".resources" do
    Permission.resources.each { |r| assert_kind_of String, r }
  end

  test ".resources works even for undefined resource types" do
    FactoryBot.create :permission, :resource_type => 'SomethingNotExisting'
    Permission.resources.each { |r| assert_not_nil r }
  end

  test ".resources_with_translations are ordered by translation" do
    Permission.stubs(:with_translations).returns([['Z', 'z'], ['A', 'b'], ['H', 'a']])
    assert_equal [['A', 'b'], ['H', 'a'], ['Z', 'z']], Permission.resources_with_translations
  end

  test "can search permissions by name" do
    permission = FactoryBot.create :permission, :domain, :name => 'view_all_domains'
    as_admin do
      permissions = Permission.search_for('name = view_all_domains')
      assert_includes permissions, permission
    end
  end

  test "can search permissions by resource_type" do
    permission = FactoryBot.create :permission, :domain, :name => 'view_all_domains'
    as_admin do
      permissions = Permission.search_for('resource_type = Domain')
      assert_includes permissions, permission
    end
  end

  test ".resource_name" do
    assert_equal 'Domain', Permission.resource_name(Domain)
  end
end
