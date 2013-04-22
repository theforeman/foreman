require 'test_helper'

class PtableTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "name can't be blank" do
    partition_table = Ptable.new :name => "   ", :layout => "any layout"
    assert partition_table.name.strip.empty?
    assert !partition_table.save
  end

  test "name can't contain trailing white spaces" do
    partition_table = Ptable.new :name => "   Archlinux        default  ", :layout => "any layout"
    assert !partition_table.name.strip.squeeze(" ").empty?
    assert !partition_table.save

    partition_table.name.strip!.squeeze!(" ")
    assert partition_table.save
  end

  test "layout can't be blank" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "   "
    assert partition_table.layout.strip.empty?
    assert !partition_table.save
  end

  test "os family can be one of defined os families" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => Operatingsystem.families[0]
    assert partition_table.save
  end

  test "os family can't be anything else than defined os families" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => "unknown"
    assert !partition_table.save
  end

  test "os family can be nil" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => nil
    assert partition_table.save
  end

  test "blank os family is converted to nil" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => ""
    assert partition_table.save
    assert partition_table.os_family.nil?
  end

  # I'm commenting this one out for now, as I'm not sure that its actully needed
  # besides, it breaks the inital db migration
  #  test "layout can't contain trailing white spaces" do
  #    partition_table = Ptable.new :name => "Archlinux default", :layout => "   any    layout   "
  #    assert !partition_table.layout.strip.squeeze(" ").empty?
  #    assert !partition_table.save
  #
  #    partition_table.layout.strip!.squeeze!(" ")
  #    assert partition_table.save
  #  end

  test "name must be unique" do
    partition_table_one = Ptable.new :name => "Archlinux default", :layout => "some layout"
    assert partition_table_one.save

    partition_table_two = Ptable.new :name => "Archlinux default", :layout => "some other layout"
    assert !partition_table_two.save
  end

  test "should not destroy while using" do
    partition_table = Ptable.new :name => "Ubuntu default", :layout => "some layout"
    assert partition_table.save

    host = hosts(:one)
    host.ptable = partition_table
    host.save(:validate => false)

    assert !partition_table.destroy
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_ptables"
      role.permissions = ["#{operation}_ptables".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Ptable.create :name => "dummy", :layout => "layout"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Ptable.create :name => "dummy", :layout => "layout"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Ptable.first
    as_admin do
      record.hosts = []
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Ptable.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Ptable.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Ptable.first
    record.name = "renamed"
    as_admin do
      record.hosts = []
    end
    assert !record.save
    assert record.valid?
  end

end
