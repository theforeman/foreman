require 'test_helper'

class PtableTest < ActiveSupport::TestCase
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

  test "layout can't contain trailing white spaces" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "   any    layout   "
    assert !partition_table.layout.strip.squeeze(" ").empty?
    assert !partition_table.save

    partition_table.layout.strip!.squeeze!(" ")
    assert partition_table.save
  end

  test "name must be unique" do
    partition_table_one = Ptable.new :name => "Archlinux default", :layout => "some layout"
    assert partition_table_one.save

    partition_table_two = Ptable.new :name => "Archlinux default", :layout => "some other layout"
    assert !partition_table_two.save
  end

  test "layout must be unique" do
    partition_table_one = Ptable.new :name => "Archlinux default", :layout => "some layout"
    assert partition_table_one.save

    partition_table_two = Ptable.new :name => "Ubuntu default", :layout => "some layout"
    assert !partition_table_two.save
  end

  test "should not destroy while using" do
    partition_table = Ptable.new :name => "Ubuntu default", :layout => "some layout"
    assert partition_table.save

    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition",
      :ptable => partition_table
    assert host.save!
    partition_table.hosts << host

    assert !partition_table.destroy
  end
end
