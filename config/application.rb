if defined?(Rake.application) && Rake.application.top_level_tasks.grep(/jenkins/).any?
  ENV['RAILS_ENV'] ||= 'test'
end
require File.expand_path('../boot', __FILE__)
require 'apipie/middleware/checksum_in_headers'
require 'rails/all'

require File.expand_path('../../config/settings', __FILE__)
require File.expand_path('../../lib/foreman/dynflow', __FILE__)

if File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
  # If there is a Gemfile.in file, we will not use Bundler but BundlerExt
  # gem which parses this file and loads all dependencies from the system
  # rathern then trying to download them from rubygems.org. It always
  # loads all gemfile groups.
  require 'bundler_ext'
  BundlerExt.system_require(File.expand_path('../../Gemfile.in', __FILE__), :all)

  class Foreman::Consoletie < Rails::Railtie
    console { Foreman.setup_console }
  end
else
  # If you have a Gemfile, require the gems listed there
  # Note that :default, :test, :development and :production groups
  # will be included by default (and dependending on the current environment)
  if defined?(Bundler)
    class Foreman::Consoletie < Rails::Railtie
      console do
        begin
          Bundler.require(:console)
        rescue LoadError
          # no action, logs a warning in setup_console only
        end
        Foreman.setup_console
      end
    end
    Bundler.require(*Rails.groups)
    if SETTINGS[:unattended]
      %w[ec2 fog gce libvirt openstack ovirt rackspace vmware].each do |group|
        begin
          Bundler.require(group)
        rescue LoadError
          # ignoring intentionally
        end
      end
    end
  end
end

# CRs in fog core with extra dependencies will have those deps loaded, so then
# load the corresponding bit of fog
require 'fog/ovirt' if defined?(::OVIRT)

require_dependency File.expand_path('../../app/models/application_record.rb', __FILE__)
require_dependency File.expand_path('../../lib/foreman.rb', __FILE__)
require_dependency File.expand_path('../../lib/timed_cached_store.rb', __FILE__)
require_dependency File.expand_path('../../lib/foreman/exception', __FILE__)
require_dependency File.expand_path('../../lib/core_extensions', __FILE__)
require_dependency File.expand_path('../../lib/foreman/logging', __FILE__)
require_dependency File.expand_path('../../lib/foreman/http_proxy', __FILE__)
require_dependency File.expand_path('../../lib/middleware/catch_json_parse_errors', __FILE__)
require_dependency File.expand_path('../../lib/middleware/tagged_logging', __FILE__)
require_dependency File.expand_path('../../lib/middleware/session_safe_logging', __FILE__)

if SETTINGS[:support_jsonp]
  if File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
    BundlerExt.system_require(File.expand_path('../../Gemfile.in', __FILE__), :jsonp)
  else
    Bundler.require(:jsonp)
  end
end

module Foreman
  class Application < Rails::Application
    # Setup additional routes by loading all routes file from routes directory
    Dir["#{Rails.root}/config/routes/**/*.rb"].each do |route_file|
      config.paths['config/routes.rb'] << route_file
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir[ Rails.root.join('app', 'models', 'power_manager') ]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/mailers"]

    config.autoload_paths += %W(#{config.root}/app/models/auth_sources)
    config.autoload_paths += %W(#{config.root}/app/models/compute_resources)
    config.autoload_paths += %W(#{config.root}/app/models/fact_names)
    config.autoload_paths += %W(#{config.root}/app/models/lookup_keys)
    config.autoload_paths += %W(#{config.root}/app/models/host_status)
    config.autoload_paths += %W(#{config.root}/app/models/operatingsystems)
    config.autoload_paths += %W(#{config.root}/app/models/parameters)
    config.autoload_paths += %W(#{config.root}/app/models/trends)
    config.autoload_paths += %W(#{config.root}/app/models/taxonomies)
    config.autoload_paths += %W(#{config.root}/app/models/mail_notifications)

    # Custom directories that will only be loaded once
    # Should only contain classes with class-level data set by initializers (registries etc.)
    config.autoload_once_paths += %W(#{config.root}/app/registries)

    # Eager load all classes under lib directory
    config.eager_load_paths += ["#{config.root}/lib"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Don't enforce known locales with exceptions, as fast_gettext has a fallback to default 'en'
    config.i18n.enforce_available_locales = false

    # Disable fieldWithErrors divs
    config.action_view.field_error_proc = Proc.new {|html_tag, instance| html_tag.to_s.html_safe }

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :account_password, :facts, :root_pass, :value, :report, :password_confirmation, :secret]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # enables in memory cache store with ttl
    #config.cache_store = TimedCachedStore.new
    config.cache_store = :file_store, Rails.root.join("tmp", "cache")

    # enables JSONP support in the Rack middleware
    config.middleware.use Rack::JSONP if SETTINGS[:support_jsonp]

    # Enable Rack OpenID middleware
    begin
      require 'rack/openid'
      require 'openid/store/filesystem'
      openid_store_path = Pathname.new(Rails.root).join('db').join('openid-store')
      config.middleware.use Rack::OpenID, OpenID::Store::Filesystem.new(openid_store_path)
    rescue LoadError
      nil
    end

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Disable noisy logging of requests for assets
    config.assets.quiet = true

    # Catching Invalid JSON Parse Errors with Rack Middleware
    if Rails::VERSION::MAJOR == 4
      config.middleware.insert_before ActionDispatch::ParamsParser, Middleware::CatchJsonParseErrors
    else
      config.middleware.use Middleware::CatchJsonParseErrors
    end

    # Record request ID in logging MDC storage
    config.middleware.insert_before Rails::Rack::Logger, Middleware::TaggedLogging
    config.middleware.insert_after ActionDispatch::Session::ActiveRecordStore, Middleware::SessionSafeLogging

    # Add apidoc hash in headers for smarter caching
    config.middleware.use Apipie::Middleware::ChecksumInHeaders

    # New config option to opt out of params "deep munging" that was used to address security vulnerability CVE-2013-0155.
    config.action_dispatch.perform_deep_munge = false

    # Use Dynflow as the backend for ActiveJob
    config.active_job.queue_adapter = :dynflow

    Foreman::Logging.configure(
      :log_directory => "#{Rails.root}/log",
      :environment => Rails.env,
      :config_overrides => SETTINGS[:logging]
    )

    # Check that the loggers setting exist to configure the app and sql loggers
    Foreman::Logging.add_loggers((SETTINGS[:loggers] || {}).reverse_merge(
      :app => {:enabled => true},
      :audit => {:enabled => true},
      :ldap => {:enabled => false},
      :permissions => {:enabled => false},
      :proxy => {:enabled => false},
      :sql => {:enabled => false},
      :templates => {:enabled => true},
      :notifications => {:enabled => true},
      :background => {:enabled => true},
      :dynflow => {:enabled => true}
    ))

    config.logger = Foreman::Logging.logger('app')
    # Explicitly set the log_level from our config, overriding the Rails env default
    config.log_level = Foreman::Logging.logger_level('app').to_sym
    config.active_record.logger = Foreman::Logging.logger('sql')

    if config.public_file_server.enabled
      ::Rails::Engine.subclasses.map(&:instance).each do |engine|
        if File.exist?("#{engine.root}/public/assets")
          config.middleware.use ::ActionDispatch::Static, "#{engine.root}/public"
        end
      end
    end

    config.to_prepare do
      ApplicationController.descendants.each do |child|
        # reinclude the helper module in case some plugin extended some in the to_prepare phase,
        # after the module was already included into controllers
        helpers = child._helpers.ancestors.find_all do |ancestor|
          ancestor.name =~ /Helper$/
        end
        child.helper helpers
      end

      Plugin.all.each do |plugin|
        plugin.to_prepare_callbacks.each(&:call)
      end
    end

    # Use the database for sessions instead of the cookie-based default
    config.session_store :active_record_store, :secure => !!SETTINGS[:require_ssl]

    def dynflow
      return @dynflow if @dynflow.present?
      @dynflow =
        if defined?(ForemanTasks)
          ForemanTasks.dynflow
        else
          ::Dynflow::Rails.new(nil, Foreman::Dynflow::Configuration.new)
        end
      @dynflow.require!
      @dynflow
    end

    # We need to mount the sprockets engine before we use the routes_reloader
    initializer(:mount_sprocket_env, :before => :sooner_routes_load) do
      if config.assets.compile
        app = Rails.application
        if Sprockets::Railtie.instance.respond_to?(:build_environment)
          app.assets = Sprockets::Railtie.instance.build_environment(app, true)
        end
        routes.prepend do
          mount app.assets => app.config.assets.prefix
        end
      end
    end

    # We use the routes_reloader before the to_prepare and eager_load callbacks
    # to make the routes load sooner than the controllers. Otherwise, the definition
    # of named routes helpers in the module significantly slows down the startup
    # of the application. Switching the order helps a lot.
    initializer(:sooner_routes_load, :before => :run_prepare_callbacks) do
      routes_reloader.execute_if_updated
    end

    config.after_initialize do
      dynflow = Rails.application.dynflow
      dynflow.eager_load_actions!
      dynflow.config.increase_db_pool_size

      unless dynflow.config.lazy_initialization
        if defined?(PhusionPassenger)
          PhusionPassenger.on_event(:starting_worker_process) do |forked|
            dynflow.initialize! if forked
          end
        else
          dynflow.initialize!
        end
      end
    end
  end

  def self.setup_console
    ENV['IRBRC'] = File.expand_path('../irbrc', __FILE__)
    User.current = User.anonymous_console_admin
    Rails.logger.warn "Console started with '#{User.current.login}' user, call User.current= to change it"
  end
end
