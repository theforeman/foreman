::Foreman::Application.dynflow.config.on_init do |world|
  StoredValuesCleanupJob.spawn_if_missing(world)
end
