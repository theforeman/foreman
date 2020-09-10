require 'test_helper'
require 'generators/plugin/migration_generator'

class PluginMigrationTest < Rails::Generators::TestCase
  tests Plugin::MigrationGenerator

  destination File.join(Dir.tmpdir, "/migration_generator_test/core")

  setup :prepare_destination
  setup do
    rm_rf(File.join(destination_root, '../test_plugin'))
    mkdir_p(File.join(destination_root, '../test_plugin'))

    rm_rf(File.join(destination_root, '../test_plugin2'))
    mkdir_p(File.join(destination_root, '../test_plugin2'))
  end

  test 'renames generated migration and copies to default folder' do
    run_generator %w(test_migration --plugin_name=test_plugin --orm=active_record)

    assert_migration('../test_plugin/db/migrate/test_migration.test_plugin.rb')
  end

  test 'renames generated migration and copies to explicitly set plugin source' do
    options = %w(test_migration --plugin_name=test_plugin --orm=active_record)
    options << "--plugin_source=#{File.join(destination_root, '../test_plugin2')}"
    run_generator options

    assert_migration('../test_plugin2/db/migrate/test_migration.test_plugin.rb')
  end

  # While debugging, make sure to override #capture method, otherwise it will
  # "steal" your debugger session
  def capture(out)
    if out == :stdout
      yield
    else
      super
    end
  end
end
