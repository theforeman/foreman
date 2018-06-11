# First, we check if there's a job already enqueued for RSS notifications
::Foreman::Application.dynflow.config.on_init do |world|
  CreateRssNotifications.spawn_if_missing(world)
end
