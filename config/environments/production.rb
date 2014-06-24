Foreman::Application.configure do |app|
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Fallback to assets pipeline if a precompiled asset is missed:
  # that's the case when an engine with it's own assets is added to Foreman later in production.
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Add the fonts path
  config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

  # Precompile additional assets
  config.assets.precompile += %w( .svg .eot .woff .ttf )

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  #  config.assets.precompile += %w()
  #
  javascript = %w(compute_resource
                  lookup_keys
                  config_template
                  ace/ace
                  ace/theme-twilight
                  ace/theme-dawn
                  ace/theme-clouds
                  ace/theme-textmate
                  ace/mode-diff
                  ace/mode-ruby
                  ace/keybinding-vim
                  ace/keybinding-emacs
                  diff
                  host_edit
                  jquery.cookie
                  host_checkbox
                  nfs_visibility
                  noVNC/base64
                  noVNC/des
                  noVNC/display
                  noVNC/input
                  noVNC/jsunzip
                  noVNC/logo
                  noVNC/playback
                  noVNC/rfb
                  noVNC/ui
                  noVNC/util
                  noVNC/websock
                  noVNC/webutil
                  noVNC
                  reports
                  spice
                  trends
                  charts
                  taxonomy_edit
                  gettext/all
                  filters
                  users
                  class_edit
                 )
  stylesheets = %w( )

  config.assets.precompile += javascript.map{|js| js + ".js"} + stylesheets + %w(background-size.htc)

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Adds plugin assets to the application digests hash if a manifest file exists for a plugin
  config.after_initialize do
    app.railties.engines.each do |engine|
      manifest_path = "#{engine.root}/public/assets/#{engine.engine_name}/manifest.yml"

      if File.file?(manifest_path)
        assets = YAML.load_file(manifest_path)

        assets.each_pair do |file, digest|
          config.assets.digests[file] = digest
        end
      end
    end
  end

  # Serve plugin static assets if the application is configured to do so
  if config.serve_static_assets
    app.railties.engines.each do |engine|
      if File.exists?("#{engine.root}/public/assets")
        app.middleware.use ::ActionDispatch::Static, "#{engine.root}/public"
      end
    end
  end

end
