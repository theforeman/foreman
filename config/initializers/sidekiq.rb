if defined?(::Sidekiq)
  Sidekiq.configure_server do |config|
    config.logger.level = ::Foreman::Logging.logger('sidekiq').level
  end
end
