require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  test ".resources" do
    Permission.resources.each {|r| assert_kind_of String, r }
  end

  test ".resources works even for undefined resource types" do
    FactoryGirl.create :permission, :resource_type => 'SomethingNotExisting'
    Permission.resources.each {|r| assert_not_nil r }
  end

  test ".resources_with_translations are ordered by translation" do
    Permission.stubs(:with_translations).returns([['Z', 'z'], ['A', 'b'], ['H', 'a']])
    assert_equal [['A', 'b'], ['H', 'a'], ['Z', 'z']], Permission.resources_with_translations
  end

end
