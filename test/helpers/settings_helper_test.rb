require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  describe '#setting_full_name_with_default' do
    test 'should include default value' do
      presenter = Foreman::SettingPresenter.new(:name => 'foo', :default => 'boo', :description => 'test foo', :full_name => 'Foo Name')
      assert_equal('Foo Name (Default: boo)', setting_full_name_with_default(presenter))
    end

    test 'without default value' do
      presenter = Foreman::SettingPresenter.new(:name => 'foo', :default => '', :description => 'test foo', :full_name => 'Foo Name')
      assert_equal('Foo Name (Default: Not set)', setting_full_name_with_default(presenter))
    end
  end

  test "create a setting with values collection " do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => proc { {:a => "a", :b => "b"} } })
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    assert_equal setting_collection_for(presenter), { :a => "a", :b => "b" }
    expects(:edit_select).with(presenter, :value, :title => setting_full_name_with_default(presenter), :select_values => { :a => "a", :b => "b" })
    value(presenter)
  end

  test "readonly setting with values collection returns readonly field" do
    options = Setting.set("test_attr", "some_description", "default_value", "full_name", "my_value", { :collection => proc { {:a => "a", :b => "b"} } })
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    presenter.expects(:readonly?).returns(true)
    expects(:readonly_field)
    value(presenter)
  end

  test "create a setting with a dynamic collection" do
    expected_hostgroup_count = Hostgroup.all.count + 1
    options = Setting.set('test_attr', 'some_description', 'default_value', 'full_name', 'my_value', { :collection => proc { Hash[:size => Hostgroup.all.count] } })
    FactoryBot.create(:hostgroup, :root_pass => '12345678')
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    assert_equal setting_collection_for(presenter), { :size => expected_hostgroup_count }
    expects(:edit_select).with(presenter, :value, :title => setting_full_name_with_default(presenter), :select_values => { :size => expected_hostgroup_count })
    value(presenter)
  end

  test "create a setting with no default of settings_type array" do
    options = Setting.set('name', 'description', [], 'full_name', '', :settings_type => 'array')
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    expects(:edit_textarea).with(presenter, :value, :title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => "No default value was set")
    value(presenter)
  end

  test "create a setting with default of settings_type array" do
    options = Setting.set('name', 'description', 'default value', 'full_name', '', :settings_type => 'array')
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    expects(:edit_textarea).with(presenter, :value, :title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => "default value")
    value(presenter)
  end

  test "create a setting with no default of settings_type string" do
    options = Setting.set('name', 'description', '', 'full_name', '', :settings_type => 'string')
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    expects(:edit_textfield).with(presenter, :value, :title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => "No default value was set")
    value(presenter)
  end

  test "create a setting with default of settings_type string" do
    options = Setting.set('name', 'description', "default value", 'full_name', '', :settings_type => 'string')
    setting = Setting.create(options)
    presenter = setting_presenter(setting)
    expects(:edit_textfield).with(presenter, :value, :title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => "default value")
    value(presenter)
  end
end
