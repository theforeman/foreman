require File.expand_path('../boot', __FILE__)
require 'apipie/middleware/checksum_in_headers'

require 'rails/all'

if File.exist?(File.expand_path('../../Gemfile.in', __FILE__))
  # If there is a Gemfile.in file, we will not use Bundler but BundlerExt
  # gem which parses this file and loads all dependencies from the system
  # rathern then trying to download them from rubygems.org. It always
  # loads all gemfile groups.
  require 'bundler_ext'
  BundlerExt.system_require(File.expand_path('../../Gemfile.in', __FILE__), :all)
else
  # If you have a Gemfile, require the gems listed there
  # Note that :default, :test, :development, :production, and :assets groups
  # will be included by default (and dependending on the current environment)
  if defined?(Bundler)
    Class.new Rails::Railtie do
      console {Foreman.setup_console}
    end
    Bundler.require(*Rails.groups(:assets => %w(development test)))
    if SETTINGS[:unattended]
      %w[ec2 fog libvirt ovirt vmware gce].each do |group|
        begin
          Bundler.require(group)
        rescue LoadError
          # ignoring intentionally
        end
      end
    end
  end
end

SETTINGS[:libvirt]   = defined?(::Fog::Libvirt) && defined?(::Libvirt)
SETTINGS[:ovirt]     = defined?(::Fog) && defined?(::OVIRT)
SETTINGS[:vmware]    = defined?(::Fog) && defined?(::RbVmomi)
SETTINGS[:gce]       = defined?(::Fog::Google) && defined?(::Google::APIClient::VERSION)
SETTINGS[:ec2]       = !!defined?(::Fog::AWS)
SETTINGS[:openstack] = SETTINGS[:rackspace] = !!defined?(::Fog)

require File.expand_path('../../lib/foreman.rb', __FILE__)
require File.expand_path('../../lib/timed_cached_store.rb', __FILE__)
require File.expand_path('../../lib/foreman/exception', __FILE__)
require File.expand_path('../../lib/core_extensions', __FILE__)

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
    config.paths["config/routes"] += Dir[Rails.root.join("config/routes/**/*.rb")]

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
    config.autoload_paths += Dir["#{config.root}/app/observers"]
    config.autoload_paths += Dir["#{config.root}/app/mailers"]

    config.autoload_paths += %W(#{config.root}/app/models/auth_sources)
    config.autoload_paths += %W(#{config.root}/app/models/compute_resources)
    config.autoload_paths += %W(#{config.root}/app/models/operatingsystems)
    config.autoload_paths += %W(#{config.root}/app/models/parameters)
    config.autoload_paths += %W(#{config.root}/app/models/trends)
    config.autoload_paths += %W(#{config.root}/app/models/taxonomies)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :host_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Disable fieldWithErrors divs
    config.action_view.field_error_proc = Proc.new {|html_tag, instance| "#{html_tag}".html_safe }

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

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # enables in memory cache store with ttl
    #config.cache_store = TimedCachedStore.new
    config.cache_store = :file_store, Rails.root.join("tmp", "cache")

    # enables JSONP support in the Rack middleware
    config.middleware.use Rack::JSONP if SETTINGS[:support_jsonp]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Catching Invalid JSON Parse Errors with Rack Middleware
    config.middleware.insert_before ActionDispatch::ParamsParser, "Middleware::CatchJsonParseErrors"

    # Add apidoc hash in headers for smarter caching
    config.middleware.use "Apipie::Middleware::ChecksumInHeaders"

    config.to_prepare do
      ApplicationController.descendants.each do |child|
        # reinclude the helper module in case some plugin extended some in the to_prepare phase,
        # after the module was already included into controllers
        helpers = child._helpers.ancestors.find_all do |ancestor|
          ancestor.name =~ /Helper$/
        end
        child.helper helpers
      end
    end
  end

  def self.setup_console
    Bundler.require(:console)
    Wirb.start
    Hirb.enable
  rescue
    warn "Failed to load console gems, starting anyway"
  ensure
    puts "For some operations a user must be set, try User.current = User.first"
  end
end
