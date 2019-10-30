# First, we check if there's a job already enqueued for Release notifications
::Foreman::Application.dynflow.config.on_init do |world|
  CreateReleaseNotifications.spawn_if_missing(world)
end
