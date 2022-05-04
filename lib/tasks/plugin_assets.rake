desc 'Compile plugin assets - called via rake plugin:assets:precompile[plugin_name]'
task 'plugin:assets:precompile', [:plugin] => [:environment] do |t, args|
  # This task will generate assets for a plugin and namespace them in
  # plugin_name/public/assets/<plugin_name>. The generated manifest.yaml found
  # in the assets directory of the plugin is used to add the asset digest paths
  # to the Rails digests list in production.rb.
  module Foreman
    class PluginAssetsTask < Sprockets::Rails::Task
      attr_accessor :plugin

      def initialize(plugin_id)
        @plugin = Foreman::Plugin.find(plugin_id) or raise("Unable to find registered plugin #{plugin_id}")

        Rails.env = 'production'
        app = Rails.application
        app.config.assets.digest = true
        app.config.assets.precompile = plugin.assets

        super(Rails.application)
      end

      def compile
        with_logger do
          manifest.compile(assets)
        end
      end

      def output
        File.join(plugin.path, 'public', 'assets')
      end

      def manifest_path
        File.join(output, plugin.id.to_s, "#{plugin.id}.json")
      end

      def manifest
        Sprockets::Manifest.new(index, output, manifest_path)
      end
    end
  end

  module Foreman
    class PluginWebpackTask
      attr_accessor :plugin

      def initialize(plugin_id)
        @plugin = Foreman::Plugin.find(plugin_id) or raise("Unable to find registered plugin #{plugin_id}")
      end

      def compile
        return unless File.exist?("#{@plugin.path}/webpack")
        return unless File.exist?("#{@plugin.path}/package.json")
        ENV["NODE_ENV"] ||= 'production'
        webpack_bin = ::Rails.root.join('node_modules/webpack/bin/webpack.js')
        config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)
        sh "node --max_old_space_size=2048 #{webpack_bin} --config #{config_file} --env.pluginName=#{@plugin.id}" # TODO: add bail in webpack 5 https://github.com/webpack/webpack/issues/7993
      end
    end
  end

  if args[:plugin]
    task = Foreman::PluginAssetsTask.new(args[:plugin])
    task.compile

    task = Foreman::PluginWebpackTask.new(args[:plugin])
    task.compile
  else
    puts "You must specify the name of the plugin (e.g. rake plugin:assets:precompile['my_plugin'])"
  end
end
