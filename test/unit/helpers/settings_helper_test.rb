require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  test "create a setting with values collection " do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => {:a => "a", :b => "b"} } )
    setting = Setting.create(options)
    assert_equal self.send("#{setting.name}_collection"), { :a => "a", :b => "b" }
    self.expects(:edit_select).with(setting, :value, :select_values => { :a => "a", :b => "b" }.to_json)
    value(setting)
  end

  test "readonly setting with values collection returns readonly field" do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => {:a => "a", :b => "b"} } )
    setting = Setting.create(options)
    setting.readonly!
    self.expects(:readonly_field)
    value(setting)
  end

  test "create a setting with a dynamic collection" do
    dynamic_hash = {:a => "a"}
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => dynamic_hash } )
    setting = Setting.create(options)
    dynamic_hash[:b] = "b"
    assert_equal self.send("#{setting.name}_collection"), { :a => "a", :b => "b" }
    self.expects(:edit_select).with(setting, :value, :select_values => { :a => "a", :b => "b" }.to_json)
    value(setting)
  end
end
