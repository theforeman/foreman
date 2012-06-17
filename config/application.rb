require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  Class.new Rails::Railtie do
    console {Foreman.setup_console}
  end
  Bundler.require(:default, Rails.env)
end

require File.expand_path('../../lib/timed_cached_store.rb', __FILE__)
require File.expand_path('../../lib/core_extensions', __FILE__)

module Foreman
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)

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

    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w(jquery)
    #config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Disable fieldWithErrors divs
    config.action_view.field_error_proc = Proc.new {|html_tag, instance| "#{html_tag}" }

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :account_password, :facts, :root_pass, :value, :report, :password_confirmation, :secret]

    config.session_store :active_record_store

    # enables in memory cache store with ttl
    #config.cache_store = TimedCachedStore.new
    config.cache_store = :file_store, Rails.root.join("tmp")
  end

  def self.setup_console
    Bundler.require(:console)
    Wirb.start
    Hirb.enable
  rescue => e
    say "Failed to load console gems, startring anyway"
  ensure
    puts "For some operations a user must be set, try User.current = User.first"
  end
end
