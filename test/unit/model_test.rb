require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "should have name" do
    m = Model.new
    assert !m.save
  end

  test "name should be unique" do
    m1 = Model.new :name => "pepe"
    assert m1.save
    m2 = Model.new :name => m1.name
    assert !m2.save
  end

  test "should not be used when destroyed" do
    m = Model.create :name => "m1"

    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    m.hosts << host
    assert !m.destroy
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_models"
      role.permissions = ["#{operation}_models".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Model.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Model.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Model.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Model.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Model.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Model.first
    record.name = "renamed"
    as_admin do
      record.hosts = []
    end
    assert !record.save
    assert record.valid?
  end

end
