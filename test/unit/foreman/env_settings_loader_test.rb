require 'test_helper'

class EnvSettingsLoaderTest < ActiveSupport::TestCase
  let(:env) { {} }
  let(:subject) { Foreman::EnvSettingsLoader.new(env: env) }

  context 'with all settings' do
    let(:env) do
      {
        'FOREMAN_UNATTENDED' => 'true',
        'FOREMAN_REQUIRE_SSL' => 'true',
        'FOREMAN_SUPPORT_JSONP' => 'false',
        'FOREMAN_MARK_TRANSLATED' => 'false',
        'FOREMAN_WEBPACK_DEV_SERVER' => 'false',
        'FOREMAN_WEBPACK_DEV_SERVER_HTTPS' => 'false',
        'FOREMAN_ASSETS_DEBUG' => 'false',
        'FOREMAN_HSTS_ENABLED' => 'false',
        'FOREMAN_RAILS' => '5.2',
        'FOREMAN_DOMAIN' => 'example.com',
        'FOREMAN_FQDN' => 'foreman.example.com',
        'FOREMAN_CORS_DOMAINS' => 'https://foreman.example.com https://www.foreman.example.com',
        'FOREMAN_LOGGING_LEVEL' => 'debug',
        'FOREMAN_LOGGING_PRODUCTION_TYPE' => 'file',
        'FOREMAN_LOGGING_PRODUCTION_LAYOUT' => 'multiline_pattern',
        'FOREMAN_TELEMETRY_PREFIX' => 'fm_rails',
        'FOREMAN_TELEMETRY_PROMETHEUS_ENABLED' => 'false',
        'FOREMAN_TELEMETRY_STATSD_ENABLED' => 'false',
        'FOREMAN_TELEMETRY_STATSD_HOST' => '127.0.0.1:8125',
        'FOREMAN_TELEMETRY_STATSD_PROTOCOL' => 'statsd',
        'FOREMAN_TELEMETRY_LOGGER_ENABLED' => 'false',
        'FOREMAN_TELEMETRY_LOGGER_LEVEL' => 'DEBUG',
        'FOREMAN_DYNFLOW_POOL_SIZE' => '5',
        'FOREMAN_RAILS_CACHE_STORE_TYPE' => 'redis',
        'FOREMAN_RAILS_CACHE_STORE_URLS' => 'redis://localhost:8479/0',
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_COMPRESS' => 'true',
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_NAMESPACE' => 'foreman',
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_CONNECT_TIMEOUT' => '30',
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_READ_TIMEOUT' => '0.2',
        'FOREMAN_RAILS_CACHE_STORE_OPTIONS_WRITE_TIMEOUT' => '0.2',
      }
    end

    test 'loads a settings hash' do
      expected = {
        unattended: true,
        require_ssl: true,
        support_jsonp: false,
        mark_translated: false,
        webpack_dev_server: false,
        webpack_dev_server_https: false,
        assets_debug: false,
        hsts_enabled: false,
        rails: '5.2',
        domain: 'example.com',
        fqdn: 'foreman.example.com',
        cors_domains: ['https://foreman.example.com', 'https://www.foreman.example.com'],
        logging: {
          level: 'debug',
          production: {
            type: 'file',
            layout: 'multiline_pattern',
          },
        },
        telemetry: {
          prefix: 'fm_rails',
          prometheus: {
            enabled: false,
          },
          statsd: {
            enabled: false,
            host: '127.0.0.1:8125',
            protocol: 'statsd',
          },
          logger: {
            enabled: false,
            level: 'DEBUG',
          },
        },
        dynflow: {
          pool_size: 5,
        },
        rails_cache_store: {
          type: 'redis',
          urls: ['redis://localhost:8479/0'],
          options: {
            compress: true,
            namespace: 'foreman',
            connect_timeout: 30.0,
            read_timeout: 0.2,
            write_timeout: 0.2,
          },
        },
      }

      assert_equal expected, subject.to_h
    end
  end

  context 'with logger settings' do
    let(:env) do
      {
        'FOREMAN_LOGGERS_SQL_ENABLED' => 'true',
        'FOREMAN_LOGGERS_SQL_LEVEL' => 'info',
        'FOREMAN_LOGGERS_PLUGIN__EXAMPLE_ENABLED' => 'true',
      }
    end

    test 'loads a settings hash for loggers' do
      expected = {
        loggers: {
          sql: {
            enabled: true,
            level: 'info',
          },
          'plugin/example': {
            enabled: true,
          },
        },
      }
      assert_equal expected, subject.to_h
    end
  end
end
