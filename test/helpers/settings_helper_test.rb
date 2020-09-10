require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  test "create a setting with values collection " do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => proc { {:a => "a", :b => "b"} } })
    setting = Setting.create(options)
    assert_equal setting.select_collection, { :a => "a", :b => "b" }
    expects(:edit_select).with(setting, :value, :title => setting.full_name_with_default, :select_values => { :a => "a", :b => "b" })
    value(setting)
  end

  test "readonly setting with values collection returns readonly field" do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => proc { {:a => "a", :b => "b"} } })
    setting = Setting.create(options)
    setting.readonly!
    expects(:readonly_field)
    value(setting)
  end

  test "create a setting with a dynamic collection" do
    expected_hostgroup_count = Hostgroup.all.count + 1
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => proc { Hash[:size => Hostgroup.all.count] } })
    FactoryBot.create(:hostgroup, :root_pass => '12345678')
    setting = Setting.create(options)
    assert_equal setting.select_collection, { :size => expected_hostgroup_count }
    expects(:edit_select).with(setting, :value, :title => setting.full_name_with_default, :select_values => { :size => expected_hostgroup_count })
    value(setting)
  end

  test "create a setting with no default of settings_type array" do
    setting = Setting.create({:name => "name",
      :value => "", :description => "description", :default => [], :settings_type => "array", :full_name => "full_name"})
    expects(:edit_textarea).with(setting, :value, :title => setting.full_name_with_default, :helper => :show_value, :placeholder => "No default value was set")
    value(setting)
  end

  test "create a setting with default of settings_type array" do
    setting = Setting.create({:name => "name",
      :value => "", :description => "description", :default => "default value", :settings_type => "array", :full_name => "full_name"})
    expects(:edit_textarea).with(setting, :value, :title => setting.full_name_with_default, :helper => :show_value, :placeholder => "default value")
    value(setting)
  end

  test "create a setting with no default of settings_type string" do
    setting = Setting.create({:name => "name",
      :value => "", :description => "description", :default => "", :settings_type => "string", :full_name => "full_name"})
    expects(:edit_textfield).with(setting, :value, :title => setting.full_name_with_default, :helper => :show_value, :placeholder => "No default value was set")
    value(setting)
  end

  test "create a setting with default of settings_type string" do
    setting = Setting.create({:name => "name",
      :value => "", :description => "description", :default => "default value", :settings_type => "string", :full_name => "full_name"})
    expects(:edit_textfield).with(setting, :value, :title => setting.full_name_with_default, :helper => :show_value, :placeholder => "default value")
    value(setting)
  end
end
