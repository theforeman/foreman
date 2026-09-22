require 'test_helper'

class ConfigSettingsTest < ActiveSupport::TestCase
  let(:settings_plugin_file) { Rails.root.join('config', 'settings.plugins.d', 'config_settings_test.yaml') }

  setup do
    @settings_plugin_dir_created = !settings_plugin_file.dirname.directory?
    FileUtils.mkdir_p(settings_plugin_file.dirname)
  end

  teardown do
    FileUtils.rm_f(settings_plugin_file)
    settings_plugin_file.dirname.rmdir if @settings_plugin_dir_created && settings_plugin_file.dirname.empty?
    reload_settings
  end

  test 'does not expand ERB in configuration files' do
    File.write(settings_plugin_file, <<~YAML)
      :erb_test: "<%= `id -un`.strip %>"
    YAML

    reload_settings

    assert_equal "<%= `id -un`.strip %>", SETTINGS[:erb_test]
  end

  test 'raises exception when trying to load malicious ruby objects' do
    File.write(settings_plugin_file, <<~YAML)
      :foo: !ruby/object:Object {}
    YAML

    assert_raises(Psych::DisallowedClass) do
      reload_settings
    end
  end

  private

  def reload_settings
    load Rails.root.join('config', 'settings.rb')
  end
end
