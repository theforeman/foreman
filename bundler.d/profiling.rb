group :profiling, optional: true do
  gem 'rack-mini-profiler'

  # For memory profiling
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs
  gem 'stackprof'
end
