desc 'Generate apipie_dsl:cache for plugin - called via rake plugin:apipie_dsl:cache[plugin_name]'
task 'plugin:apipie_dsl:cache', :engine do |t, args|
  if args[:engine]
    # Partially load the Rails environment to avoid
    # the need of a database being setup
    Rails.application.initialize!

    path_name = args[:engine].tr('-', '_')
    @engine = "#{path_name.camelize}::Engine".constantize
    @engine_root = @engine.root

    plugin = Foreman::Plugin.find(args[:engine])

    dsl_classes = plugin.apipie_dsl_documented_classes || [
      "#{@engine_root}/app/models/**/*.rb",
      "#{@engine_root}/app/lib/#{path_name}/renderer/**/*.rb",
    ]
    ApipieDSL.configuration.dsl_classes_matchers = dsl_classes
    ApipieDSL.configuration.sections = plugin.apipie_dsl_sections || [path_name.delete_prefix('foreman_')]

    Rake::Task['apipie_dsl:cache'].execute
  else
    puts "You must specify the name of the plugin (e.g. rake plugin:apipie_dsl:cache['my_plugin'])"
  end
end
