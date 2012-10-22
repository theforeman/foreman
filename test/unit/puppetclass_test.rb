require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name can't contain trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   test     class   "
    assert !puppet_class.name.strip.squeeze(" ").empty?
    assert !puppet_class.save

    puppet_class.name.strip!.squeeze!(" ")
    assert puppet_class.save
  end

  test "name must be unique" do
    puppet_class = Puppetclass.new :name => "test class"
    assert puppet_class.save

    other_puppet_class = Puppetclass.new :name => "test class"
    assert !other_puppet_class.save
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_puppetclasses"
      role.permissions = ["#{operation}_puppetclasses".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Puppetclass.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Puppetclass.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Puppetclass.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Puppetclass.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Puppetclass.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Puppetclass.first
    record.name = "renamed"
    as_admin do
      record.hosts = []
    end
    assert !record.save
    assert record.valid?
  end

  test "count hosts for puppet class" do
    puppet_class =  puppetclasses(:one)
    #puppetclasses(:one) is on hosts(:one) through host_classes and two more hosts that are in hostgroups(:common)
    assert_equal 3, puppet_class.count_hosts
  end

end
