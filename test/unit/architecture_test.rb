require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should_not allow_value('  ').for(:name)

  test "to_s retrieves name" do
    architecture = Architecture.new :name => "i386"
    assert architecture.to_s == architecture.name
  end

  test "should not destroy while using" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    host = FactoryGirl.create(:host)
    host.architecture = architecture
    host.save(:validate => false)

    assert_not architecture.destroy
  end

  test "should return intel precision for i386" do
    architecture = Architecture.new :name => "i386"
    assert_equal "ia32", architecture.intel_precision
  end

  test "should return intel precision for i686" do
    architecture = Architecture.new :name => "i686"
    assert_equal "ia32", architecture.intel_precision
  end

  test "should return intel precision for x86-64" do
    architecture = Architecture.new :name => "x86-64"
    assert_equal "x64", architecture.intel_precision
  end

  test "should return intel precision for x86_64" do
    architecture = Architecture.new :name => "x86_64"
    assert_equal "x64", architecture.intel_precision
  end

  test "should not return intel precision for unknown arch" do
    architecture = Architecture.new :name => "unknown"
    assert_equal "", architecture.intel_precision
  end
end
