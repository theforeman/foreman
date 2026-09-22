require 'test_helper'
require 'rake'

class PluginApipieTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/plugin_apipie'
    @apipie_cache_task = Rake::Task.define_task('apipie:cache')
    Rake::Task['plugin:apipie:cache'].reenable
    @api_controllers_matcher = Apipie.configuration.api_controllers_matcher
    @ignored_controllers = Apipie.configuration.ignored
  end

  teardown do
    Apipie.configuration.api_controllers_matcher = @api_controllers_matcher
    Apipie.configuration.ignored = @ignored_controllers
  end

  test 'uses engine name for the default controller path' do
    engine = stub(:root => Pathname.new('/plugin'), :engine_name => 'plugin_engine')
    plugin = stub(
      :engine => engine,
      :apipie_ignored_controllers => nil,
      :apipie_documented_controllers => nil
    )
    Foreman::Plugin.expects(:find).with('plugin-id').returns(plugin)
    Rails.application.stubs(:initialize!)
    @apipie_cache_task.expects(:execute)

    Rake::Task['plugin:apipie:cache'].invoke('plugin-id')

    assert_equal ['/plugin/app/controllers/plugin_engine/api/*.rb'], Apipie.configuration.api_controllers_matcher
  end
end
