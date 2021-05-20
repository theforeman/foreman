module Foreman
  class EnvSettingsLoader
    attr_reader :env

    def initialize(env: ENV)
      @env = env
    end

    def to_h
      result_hash = {}
      settings_map.each do |env_key, definition|
        value = env[env_key]
        next unless value

        type = definition.shift

        value = cast_value(type: type, value: value)

        path = definition + [value]
        hsh = path.reverse.inject { |mem, key| {key => mem} }

        result_hash.deep_merge!(hsh)
      end
      result_hash
    end

    private

    def settings_map
      {
        'FOREMAN_UNATTENDED' => [:boolean, :unattended],
        'FOREMAN_REQUIRE_SSL' => [:boolean, :require_ssl],
        'FOREMAN_SUPPORT_JSONP' => [:boolean, :support_jsonp],
        'FOREMAN_MARK_TRANSLATED' => [:boolean, :mark_translated],
        'FOREMAN_WEBPACK_DEV_SERVER' => [:boolean, :webpack_dev_server],
        'FOREMAN_WEBPACK_DEV_SERVER_HTTPS' => [:boolean, :webpack_dev_server_https],
        'FOREMAN_ASSETS_DEBUG' => [:boolean, :assets_debug],
        'FOREMAN_HSTS_ENABLED' => [:boolean, :hsts_enabled],
        'FOREMAN_RAILS' => [:string, :rails],
        'FOREMAN_DOMAIN' => [:string, :domain],
        'FOREMAN_FQDN' => [:string, :fqdn],
        'FOREMAN_CORS_DOMAINS' => [:list, :cors_domains],
        'FOREMAN_LOGGING_LEVEL' => [:string, :logging, :level],
        'FOREMAN_LOGGING_PRODUCTION_TYPE' => [:string, :logging, :production, :type],
        'FOREMAN_LOGGING_PRODUCTION_LAYOUT' => [:string, :logging, :production, :layout],
        'FOREMAN_TELEMETRY_PREFIX' => [:string, :telemetry, :prefix],
        'FOREMAN_TELEMETRY_PROMETHEUS_ENABLED' => [:boolean, :telemetry, :prometheus, :enabled],
        'FOREMAN_TELEMETRY_STATSD_ENABLED' => [:boolean, :telemetry, :statsd, :enabled],
        'FOREMAN_TELEMETRY_STATSD_HOST' => [:string, :telemetry, :statsd, :host],
        'FOREMAN_TELEMETRY_STATSD_PROTOCOL' => [:string, :telemetry, :statsd, :protocol],
        'FOREMAN_TELEMETRY_LOGGER_ENABLED' => [:boolean, :telemetry, :logger, :enabled],
        'FOREMAN_TELEMETRY_LOGGER_LEVEL' => [:string, :telemetry, :logger, :level],
        'FOREMAN_DYNFLOW_POOL_SIZE' => [:integer, :dynflow, :pool_size],
        'FOREMAN_RAILS_CACHE_STORE_TYPE' => [:string, :rails_cache_store, :type],
        'FOREMAN_RAILS_CACHE_STORE_URLS' => [:list, :rails_cache_store, :urls],
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_COMPRESS' => [:boolean, :rails_cache_store, :options, :compress],
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_NAMESPACE' => [:string, :rails_cache_store, :options, :namespace],
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_CONNECT_TIMEOUT' => [:float, :rails_cache_store, :options, :connect_timeout],
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_READ_TIMEOUT' => [:float, :rails_cache_store, :options, :read_timeout],
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_WRITE_TIMEOUT' => [:float, :rails_cache_store, :options, :write_timeout],
      }.merge(logger_settings_map)
    end

    def logger_settings_map
      loggers_from_env.each_with_object({}) do |logger, hsh|
        env_key = logger.to_s.upcase.gsub('/', '__')
        hsh["FOREMAN_LOGGERS_#{env_key}_ENABLED"] = [:boolean, :loggers, logger, :enabled]
        hsh["FOREMAN_LOGGERS_#{env_key}_LEVEL"] = [:string, :loggers, logger, :level]
        hsh
      end
    end

    def loggers_from_env
      @loggers_from_env ||= begin
        loggers_from_env_regexp = /^FOREMAN_LOGGERS_([A-Z0-9_]+)_[A-Z]+$/
        env.keys.grep(loggers_from_env_regexp).map { |key| key.gsub(loggers_from_env_regexp, '\1').downcase.gsub('__', '/').to_sym }.uniq
      end
    end

    def cast_value(type:, value:)
      case type
      when :integer
        value.to_i
      when :float
        value.to_f
      when :boolean
        !%w[0 false].include?(value.strip.downcase)
      when :list
        value.split(/[ ,]/)
      when :dict
        Hash[value.split(/[&,]/).map { |kv| kv.split('=') }]
      when :string
        value
      else
        raise "Unsupported type #{type} in definition for settings environment variable #{env_key}"
      end
    end
  end
end
