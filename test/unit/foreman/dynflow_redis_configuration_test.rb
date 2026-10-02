require 'test_helper'
require 'foreman/dynflow_redis_configuration'

class Foreman::DynflowRedisConfigurationTest < ActiveSupport::TestCase
  test 'returns no override without a CA file' do
    assert_nil Foreman::DynflowRedisConfiguration.from_env('DYNFLOW_REDIS_URL' => 'redis://localhost:6379/6')
  end

  test 'configures peer-verified TLS' do
    options = Foreman::DynflowRedisConfiguration.from_env(
      'DYNFLOW_REDIS_URL' => 'rediss://redis.example.test:6379/6',
      'DYNFLOW_REDIS_SSL_CA_FILE' => '/etc/foreman/redis-ca.crt'
    )

    assert_equal 'rediss://redis.example.test:6379/6', options[:url]
    assert_equal '/etc/foreman/redis-ca.crt', options.dig(:ssl_params, :ca_file)
    assert_equal OpenSSL::SSL::VERIFY_PEER, options.dig(:ssl_params, :verify_mode)
  end

  test 'rejects a CA file with a plaintext URL' do
    error = assert_raises RuntimeError do
      Foreman::DynflowRedisConfiguration.from_env(
        'DYNFLOW_REDIS_URL' => 'redis://redis.example.test:6379/6',
        'DYNFLOW_REDIS_SSL_CA_FILE' => '/etc/foreman/redis-ca.crt'
      )
    end

    assert_match 'requires a rediss URL', error.message
  end
end
