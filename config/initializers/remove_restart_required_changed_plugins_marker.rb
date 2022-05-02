Rails.application.config.after_initialize do
  FileUtils.rm_f("#{Rails.root}/tmp/restart_required_changed_plugins")
end
