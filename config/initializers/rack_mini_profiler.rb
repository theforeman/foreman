if defined? Rack::MiniProfiler
  # enable profiling for all pages; per-default it is disabled on production-env
  Rack::MiniProfiler.config.authorization_mode = SETTINGS.fetch(:profiler_authorization_mode, :allow_all)

  # enable additional profiling-features
  Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
end
