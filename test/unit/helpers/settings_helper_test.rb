require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  test "create a setting with values collection " do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => Proc.new {{:a => "a", :b => "b"}} })
    setting = Setting.create(options)
    assert_equal self.send("#{setting.name}_collection"), { :a => "a", :b => "b" }
    self.expects(:edit_select).with(setting, :value, :title => setting.full_name, :select_values => { :a => "a", :b => "b" })
    value(setting)
  end

  test "readonly setting with values collection returns readonly field" do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => Proc.new {{:a => "a", :b => "b"}} })
    setting = Setting.create(options)
    setting.readonly!
    self.expects(:readonly_field)
    value(setting)
  end

  test "create a setting with a dynamic collection" do
    expected_hostgroup_count = Hostgroup.all.count + 1
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => Proc.new {Hash[:size => Hostgroup.all.count]} })
    FactoryGirl.create(:hostgroup, :root_pass => '12345678')
    setting = Setting.create(options)
    assert_equal self.send("#{setting.name}_collection"), { :size => expected_hostgroup_count }
    self.expects(:edit_select).with(setting, :value, :title => setting.full_name, :select_values => { :size => expected_hostgroup_count })
    value(setting)
  end
end
