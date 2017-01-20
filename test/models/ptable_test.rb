require 'test_helper'

class PtableTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should_not allow_value('  ').for(:name)
  should validate_uniqueness_of(:name)
  should validate_presence_of(:layout)

  test "name strips leading and trailing white spaces" do
    partition_table = Ptable.new :name => "   Archlinux        default  ", :layout => "any layout"
    assert partition_table.save

    refute partition_table.name.ends_with?(' ')
    refute partition_table.name.starts_with?(' ')
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

  test "should not destroy while using" do
    partition_table = Ptable.new :name => "Ubuntu default", :layout => "some layout"
    assert partition_table.save

    host = FactoryGirl.create(:host)
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

  test '#preview_host_collection obeys view_hosts permission' do
    Host.expects(:authorized).with(:view_hosts).returns(Host.where(nil))
    Ptable.preview_host_collection
  end

  test "#metadata should include OS family" do
    ptable = FactoryGirl.build(:ptable)

    lines = ptable.metadata.split("\n")
    assert_includes lines, "os_family: #{ptable.os_family}"
    assert_includes lines, "name: #{ptable.name}"
  end
end
