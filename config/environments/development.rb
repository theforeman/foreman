Foreman::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Eager load is set for all environments
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Should ANSI color codes be used when logging information
  config.colorize_logging = Foreman::Logging.config[:colorize]

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = SETTINGS.fetch(:assets_debug, true)

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # log on mass assignment of unfiltered parameters
  config.action_controller.action_on_unpermitted_parameters = :log

  # include query source line when sql logging is enabled
  config.active_record.verbose_query_logs = Foreman::Logging.logger('sql')

  if defined?(Bullet)
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.add_footer = true
      Bullet.counter_cache_enable = false
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Puppetclass", :association => :environments
      Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Puppetclass", :association => :class_params
    end
  end

  # Allow disabling the webpack dev server from the settings
  config.webpack.dev_server.enabled = SETTINGS.fetch(:webpack_dev_server, true)
  config.webpack.dev_server.https = SETTINGS.fetch(:webpack_dev_server_https, false)
  config.hosts << SETTINGS[:fqdn]
end
