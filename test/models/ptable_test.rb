require 'test_helper'

class PtableTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)

  should validate_presence_of(:layout)
  should allow_values(*valid_name_list).for(:layout)
  should_not allow_values('', ' ', nil).for(:layout)

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
    assert_nil partition_table.os_family
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

    host = FactoryBot.create(:host)
    host.ptable = partition_table
    host.save(:validate => false)

    assert !partition_table.destroy
  end

  test '#preview_host_collection obeys view_hosts permission' do
    Host.expects(:authorized).with(:view_hosts).returns(Host.where(nil))
    Ptable.preview_host_collection
  end

  test "#metadata should include OS family" do
    ptable = FactoryBot.build_stubbed(:ptable)

    lines = ptable.metadata.split("\n")
    assert_includes lines, "os_family: #{ptable.os_family}"
    assert_includes lines, "name: #{ptable.name}"
  end

  context 'importing' do
    describe '#import_custom_data' do
      test 'it sets the family based on assigned oses' do
        template = Ptable.new
        os1 = FactoryBot.create(:debian7_0)
        os2 = FactoryBot.create(:suse)
        template.operatingsystem_ids = [os1.id, os2.id]
        template.stubs :import_oses => true
        template.instance_variable_set '@importing_metadata', { 'oses' => ['Debian'] }
        template.send(:import_custom_data, { :associate => 'always' })
        assert_equal 'Debian', template.os_family
      end
    end
  end

  test 'should be invalid when snippet has os_family' do
    ptable = Ptable.new(:name => 'invalid snippet', :snippet => true, :os_family => 'Debian', :template => 'foo')
    ptable.save
    refute ptable.valid?
    assert_equal ['must be blank'], ptable.errors.messages[:os_family]
  end
end
