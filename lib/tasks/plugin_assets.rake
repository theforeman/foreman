desc 'Compile engine assets - called via rake plugin:assets:precompile[plugin_name]'
task 'plugin:assets:precompile', [:engine] do |t, args|
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
      attr_accessor :engine

      def initialize(engine_name)
        @engine = "#{engine_name.camelize}::Engine".constantize

        env = Rails.application.assets
        app = Rails.application

        config = Rails.application.config
        config.assets.digest = true

        Rails.application.config.assets.precompile = SETTINGS[@engine.engine_name.to_sym][:assets][:precompile]

        env.register_engine '.scss', Sass::Rails::ScssTemplate
        env.js_compressor = :uglifier
        env.css_compressor = :sass
        env.cache = nil

        env.context_class.class_eval do
          class_attribute :sass_config
          self.sass_config = app.config.sass
          self.assets_prefix = config.assets.prefix
          self.digest_assets = config.assets.digest
        end

        super(Rails.application)
      end

      def compile
        with_logger do
          manifest.compile(assets)
        end
      end

      def environment
        env = Rails.application.assets
        config = Rails.application.config

        Rails.application.config.assets.paths.each do |path|
          env.append_path path
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
        File.join(@engine.root, 'public', 'assets')
      end

      def manifest_path
        File.join(output, @engine.engine_name, "#{@engine.engine_name}.json")
      end

      def manifest
        Sprockets::Manifest.new(index, output, manifest_path)
      end
    end
  end

  if args[:engine]
    # Partially load the Rails environment to avoid
    # the need of a database being setup
    Rails.application.initialize!(:assets)
    task = Foreman::PluginAssetsTask.new(args[:engine])
    task.compile
  else
    puts "You must specify the name of the plugin (e.g. rake plugin:assets:precompile['my_plugin'])"
  end
end
