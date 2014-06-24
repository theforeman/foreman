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
    assert !partition_table.name.squeeze(" ").empty?
    assert !partition_table.save

    partition_table.name.squeeze!(" ")
    assert partition_table.save
  end

  test "layout can't be blank" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "   "
    assert partition_table.layout.strip.empty?
    assert !partition_table.save
  end

  test "os family can be one of defined os families" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => Operatingsystem.families[0]
    assert partition_table.valid?
  end

  test "os family can't be anything else than defined os families" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => "unknown"
    assert !partition_table.valid?
  end

  test "os family can be nil" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => nil
    assert partition_table.valid?
  end

  test "setting os family to a blank string is valid" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => ""
    assert partition_table.valid?
  end

  test "blank os family is saved as nil" do
    partition_table = Ptable.new :name => "Archlinux default", :layout => "any layout", :os_family => ""
    assert_equal nil, partition_table.os_family
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

  test 'when creating a new ptable class object, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        Ptable.create! :name => "dummy", :layout => "layout"
      end
    end
  end

end
