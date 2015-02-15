desc 'Compile engine assets - called via rake plugin:assets:precompile[plugin_name]'
task 'plugin:assets:precompile', :engine do |t, args|
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

  def compile_assets(args = {})
    _ = ActionView::Base

    app = Rails.application
    assets = app.config.assets
    env = app.assets
    target = File.join(@engine_root, 'public', 'assets')

    assets.digests        = {}
    assets.manifest       = File.join(target, @engine.engine_name)
    assets.compile        = SETTINGS[@engine.engine_name.to_sym][:assets][:compile] || assets.compile
    assets.compress       = SETTINGS[@engine.engine_name.to_sym][:assets][:compress] || assets.compress
    assets.digest         = args.fetch(:digest, true)
    assets.js_compressor  = SETTINGS[@engine.engine_name.to_sym][:assets][:js_compressor]

    precompile = SETTINGS[@engine.engine_name.to_sym][:assets][:precompile]
    precompile = fix_indexes(precompile)

    Sprockets::Bootstrap.new(Rails.application).run
    compiler = Sprockets::StaticCompiler.new(env,
                                             target,
                                             precompile,
                                             :manifest_path => assets.manifest,
                                             :digest => assets.digest,
                                             :manifest => true)
    compiler.compile
  end

  # Used to add index manifest files to the paths for
  # proper resolution and addition when running Rails 3.2.8
  # in the SCL
  def fix_indexes(precompile)
    if Rails.version == '3.2.8'
      precompile.each do |asset|
        if File.basename(asset)[/[^\.]+/, 0] == 'index'
          asset.sub!(/\/index\./, '.')
          precompile << asset
        end
      end
    end

    precompile
  end

  if args[:engine]
    # Partially load the Rails environment to avoid
    # the need of a database being setup
    Rails.application.initialize!(:assets)

    @engine = "#{args[:engine].camelize}::Engine".constantize
    @engine_root = @engine.root

    compile_assets(:digest => false)
    compile_assets
  else
    puts "You must specify the name of the plugin (e.g. rake plugin:assets:precompile['my_plugin'])"
  end
end
