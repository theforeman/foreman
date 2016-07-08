require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  test "readonly setting with values collection returns readonly field" do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => Proc.new {{:a => "a", :b => "b"}} })
    setting = Setting.create(options)
    setting.readonly!
    self.expects(:readonly_field)
    value(setting)
  end
end
