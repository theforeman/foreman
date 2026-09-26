if defined?(::Sidekiq)
  require 'foreman/dynflow_redis_configuration'

  redis_options = Foreman::DynflowRedisConfiguration.from_env
  Sidekiq.configure_server do |config|
    config.logger.level = ::Foreman::Logging.logger('sidekiq').level
    config.redis = redis_options if redis_options
  end
  Sidekiq.configure_client { |config| config.redis = redis_options } if redis_options
end
