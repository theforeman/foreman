require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include SettingsHelper

  let(:setting) { Foreman.settings.find('entries_per_page') }

  test "settings are readonly for users with only view permission" do
    setup_user('view', 'settings')

    assert_equal true, setting_to_hash(setting)[:readonly]
  end

  test "settings are editable for users with edit permission" do
    setup_user('edit', 'settings')

    assert_equal false, setting_to_hash(setting)[:readonly]
  end

  test "settings are editable for administrators" do
    as_admin do
      assert_equal false, setting_to_hash(setting)[:readonly]
    end
  end

  [true, false].each do |can_edit|
    test "grouping settings checks edit permission once when permission is #{can_edit}" do
      setup_user('view', 'settings')
      User.current.expects(:can?).with(:edit_settings).once.returns(can_edit)
      settings = [setting, Foreman.settings.find('administrator')]

      grouped = grouped_settings(settings)

      assert_equal settings.map(&:category_name).uniq.sort, grouped.keys.sort
      assert_equal settings.map(&:name).sort, grouped.values.flatten.map { |s| s[:name] }.sort
      grouped.values.flatten.each do |serialized_setting|
        assert_equal !can_edit, serialized_setting[:readonly]
      end
    end
  end

  test "settings controlled by configuration remain readonly with edit permission" do
    setup_user('edit', 'settings')
    SETTINGS[:entries_per_page] = 50

    assert_equal true, setting_to_hash(setting)[:readonly]
  ensure
    SETTINGS.delete(:entries_per_page)
  end

  test "config_file is not exposed for settings overridden via configuration" do
    setup_user('edit', 'settings')
    SETTINGS[:entries_per_page] = 50
    assert_not_includes setting_to_hash(setting), :config_file
  ensure
    SETTINGS.delete(:entries_per_page)
  end

  test "config_file is not exposed when readonly only due to missing permission" do
    setup_user('view', 'settings')
    assert_not_includes setting_to_hash(setting), :config_file
  end
end
