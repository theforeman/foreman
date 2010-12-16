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
    assert !architecture.name.strip.squeeze(" ").tr(' ', '').empty?
    assert !architecture.save

    architecture.name.strip!.squeeze!(" ").tr!(' ', '')
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
    architecture.hosts << host

    assert !architecture.destroy
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_architectures"
      role.permissions = ["#{operation}_architectures".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Architecture.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Architecture.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Architecture.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Architecture.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Architecture.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Architecture.first
    record.name = "renamed"
    assert !record.save
  end
end
