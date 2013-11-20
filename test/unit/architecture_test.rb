require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login("admin")
  end
  test "should not save without a name" do
    architecture = Architecture.new
    assert !architecture.save
  end

  test "name should not be blank" do
    architecture = Architecture.new :name => "   "
    assert architecture.name.strip.empty?
    assert !architecture.save
  end

  test "name should not contain white spaces" do
    architecture = Architecture.new :name => " i38  6 "
    assert !architecture.name.squeeze(" ").tr(' ', '').empty?
    assert !architecture.save

    architecture.name.squeeze!(" ").tr!(' ', '')
    assert architecture.save
  end

  test "name should be unique" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    other_architecture = Architecture.new :name => "i386"
    assert !other_architecture.save
  end

  test "to_s retrives name" do
    architecture = Architecture.new :name => "i386"
    assert architecture.to_s == architecture.name
  end

  test "should not destroy while using" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    host = hosts(:one)
    host.architecture = architecture
    host.save(:validate => false)

    assert !architecture.destroy
  end

end
