rails_root = Dir.pwd

app_file = File.expand_path('./config/application', rails_root)
require app_file

rails_env_file = File.expand_path('./config/environment.rb', rails_root)
require rails_env_file

redis_url = SETTINGS.dig(:dynflow, :redis_url)
Sidekiq.redis = { url: redis_url }

if Sidekiq.options[:queues].include?("dynflow_orchestrator")
  ::Rails.application.dynflow.executor!
elsif (Sidekiq.options[:queues] - ['dynflow_orchestrator']).any?
  ::Rails.application.dynflow.config.remote = true
end

world_id = nil
::Rails.application.dynflow.config.on_init(false) do |world|
  world_id = world.id
  Sidekiq.options[:dynflow_world] = world
end

::Rails.application.dynflow.initialize!
Rails.logger.info("Everything ready for world: #{world_id}")
