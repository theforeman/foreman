Rails.application.config.after_initialize do
  Foreman::Plugin.registered_plugins.each_value(&:finalize_setup!)
end
