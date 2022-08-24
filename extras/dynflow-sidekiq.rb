require "sidekiq/sd_notify"

rails_root = Dir.pwd

app_file = File.expand_path('./config/application', rails_root)
require app_file

::Rails.application.dynflow.config.lazy_initialization = true
::Rails.application.dynflow.config.on_init(false) do |world|
  # Loading and initializing of all gettext languages takes about 100ms per language
  # in development environment and little less on production. Let's eager load languages
  # but only for production.
  FastGettext.human_available_locales
end

rails_env_file = File.expand_path('./config/environment.rb', rails_root)
require rails_env_file

if Sidekiq.options[:queues].include?("dynflow_orchestrator")
  Sidekiq.options[:dynflow_executor] = true
  ::Rails.application.dynflow.executor!
elsif (Sidekiq.options[:queues] - ['dynflow_orchestrator']).any?
  ::Rails.application.dynflow.config.remote = true
end

::Rails.application.dynflow.config.on_init(false) do |world|
  Sidekiq.options[:dynflow_world] = world
end

# To be able to ensure ordering, dynflow requires that there is only one
# orchestrator active at the same time.
# This is enforced by orchestrators contending a lock in redis, calls to
# dynflow.initialize! block until the lock is acquired by the current process.
# To play nice with sd_notify, we need to mark the process as ready before it
# attempts to acquire the lock.
if Sidekiq.options[:dynflow_executor]
  Sidekiq::SdNotify.ready
  Sidekiq::SdNotify.status('orchestrator in passive mode')
end
::Rails.application.dynflow.initialize!
msg = "Everything ready for world: #{::Rails.application.dynflow.world.id}"
Rails.logger.info(msg)
Sidekiq::SdNotify.status(msg)
