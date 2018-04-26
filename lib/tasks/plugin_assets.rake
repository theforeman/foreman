desc 'Compile plugin assets - called via rake plugin:assets:precompile[plugin_name]'
task 'plugin:assets:precompile', [:plugin] => [:environment] do |t, args|
  # This task will generate assets for a plugin and namespace them in
  # plugin_name/public/assets/<plugin_name>. The generated manifest.yaml found
  # in the assets directory of the plugin is used to add the asset digest paths
  # to the Rails digests list in production.rb.
  #
  # The task expects a plugin to define their assets to precompile using SETTINGS.
  # This can be done via a settings yaml file or if the deinfition requires
  # complexity through the use of an initializer in the plugins engine.rb.
  #
  # Example: Simple Precompile List
  #
  #   SETTINGS[:plugin_name] = {
  #     :assets => {
  #       :precompile => [
  #         'plugin_name/plugin.css',
  #         'plugin_name/plugin.js',
  #         'plugin_name/another_js_file.js
  #       ],
  #     }
  #   }
  #
  # Example: Custom JS Compressor
  #
  #   SETTINGS[:plugin_name] = {
  #     :assets => {
  #       :precompile => [
  #         'plugin_name/plugin.css',
  #         'plugin_name/plugin.js',
  #         'plugin_name/another_js_file.js
  #       ],
  #       :js_compressor => Uglifier.new(:mangle => false)
  #     }
  #   }

  module Foreman
    class PluginAssetsTask < Sprockets::Rails::Task
      attr_accessor :plugin

      def initialize(plugin_id)
        @plugin = Foreman::Plugin.find(plugin_id) or raise("Unable to find registered plugin #{plugin_id}")

        app = Rails.application
        env = app.assets || Sprockets::Environment.new(app.root.to_s)

        config = Rails.application.config
        config.assets.digest = true

        Rails.application.config.assets.precompile = plugin.assets

        env.register_transformer 'text/scss', 'text/css',
          Sprockets::ScssProcessor.new(
            importer: Sass::Rails::SassImporter,
            sass_config: app.config.sass)
        env.js_compressor = :uglifier
        env.css_compressor = :sass
        env.cache = nil

        env.context_class.class_eval do
          class_attribute :sass_config
          self.sass_config = app.config.sass
        end

        super(Rails.application)
      end

      def compile
        environment.context_class.class_eval do
          def asset_path(path, options = {})
            ActionController::Base.helpers.asset_path(path, options)
          end
        end

        with_logger do
          manifest.compile(assets)
        end
      end

      def environment
        app    = Rails.application
        config = app.config
        env    = app.assets || Sprockets::Environment.new(app.root.to_s)

        Rails.application.config.assets.paths.each do |path|
          env.append_path path
        end

        env.context_class.class_eval do
          def asset_path(path, options = {})
            ActionController::Base.helpers.asset_path(path, options)
          end
        end

        env.version = [
          'production',
          config.assets.version,
          config.action_controller.relative_url_root,
          (config.action_controller.asset_host unless config.action_controller.asset_host.respond_to?(:call)),
          Sprockets::Rails::VERSION
        ].compact.join('-')

        env
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
        return unless File.exist?("#{@plugin.path}/package.json")
        ENV["NODE_ENV"] ||= 'production'
        webpack_bin = ::Rails.root.join('node_modules/webpack/bin/webpack.js')
        config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)
        sh "#{webpack_bin} --config #{config_file} --bail --env.pluginName=#{@plugin.id}"
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
