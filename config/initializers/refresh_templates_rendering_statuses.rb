::Foreman::Application.dynflow.config.on_init do |world|
  RefreshTemplatesRenderingStatusesJob.spawn_if_missing(world)
end
