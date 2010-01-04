require 'test_helper'

class PtableTest < ActiveSupport::TestCase
  test "name can't be blank" do
    partition_table = Ptable.new :name => "   ", :layout => "any layout"
    assert partition_table.name.strip.empty?
    assert !partition_table.save
  end

  test "name can't contain trailing whitespaces" do
    partition_table = Ptable.new :name => "   Archlinux default  ", :layout => "any layout"
    assert !partition_table.name.strip.empty?
    assert !partition_table.save

    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout"
    assert partition_table.save
  end

  test "layout can't be blank" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "   "
    assert partition_table.layout.strip.empty?
    assert !partition_table.save
  end

  test "layout can't contain trailing whitespaces" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "   any layout   "
    assert !partition_table.save

    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout"
    assert partition_table.save
  end
end
