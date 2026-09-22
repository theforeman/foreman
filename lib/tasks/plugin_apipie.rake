desc 'Generate apipie:cache for plugin - called via rake plugin:apipie:cache[plugin_name]'
task 'plugin:apipie:cache', :engine do |t, args|
  if args[:engine]
    # Partially load the Rails environment to avoid
    # the need of a database being setup
    Rails.application.initialize!

    plugin = Foreman::Plugin.find(args[:engine]) or raise("Unable to find registered plugin #{args[:engine]}")
    @engine = plugin.engine
    @engine_root = @engine.root

    Apipie.configuration.ignored = plugin.apipie_ignored_controllers || []
    default_controllers = ["#{@engine_root}/app/controllers/#{@engine.engine_name}/api/*.rb"]
    api_controllers = plugin.apipie_documented_controllers || default_controllers
    Apipie.configuration.api_controllers_matcher = api_controllers

    Rake::Task['apipie:cache'].execute
  else
    puts "You must specify the name of the plugin (e.g. rake plugin:apipie:cache['my_plugin'])"
  end
end
