require 'test_helper'
require 'fileutils'

class ConfigSettingsTest < ActiveSupport::TestCase
  let(:settings_d_file) { Rails.root.join('config/settings.d/settings_loader_test.yaml') }
  let(:settings_plugins_d_file) { Rails.root.join('config/settings.plugins.d/settings_loader_test.yaml') }

  teardown do
    cleanup_test_file(settings_d_file)
    cleanup_test_file(settings_plugins_d_file)
    reload_settings
  end

  test 'loads settings from settings.plugins.d before settings.d' do
    FileUtils.mkdir_p(settings_d_file.dirname)
    File.write(settings_d_file, <<~YAML)
      :settings_d_only_test: from_settings_d
      :settings_loader_precedence_test: from_settings_d
    YAML

    FileUtils.mkdir_p(settings_plugins_d_file.dirname)
    File.write(settings_plugins_d_file, <<~YAML)
      :settings_loader_precedence_test: from_settings_plugins_d
    YAML

    reload_settings

    assert_equal 'from_settings_d', SETTINGS[:settings_d_only_test]
    assert_equal 'from_settings_d', SETTINGS[:settings_loader_precedence_test]
  end

  private

  def reload_settings
    silence_warnings { load Rails.root.join('config/settings.rb').to_s }
  end

  def cleanup_test_file(path)
    File.delete(path) if File.exist?(path)
    Dir.rmdir(path.dirname) if Dir.exist?(path.dirname) && Dir.empty?(path.dirname)
  rescue SystemCallError
    nil
  end
end
