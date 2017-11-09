require "benchmark/benchmark_helper"
require 'memory_profiler'
require "stackprof"

def with_memory_profiler
  report = MemoryProfiler.report do
    yield
  end
  report.pretty_print
end

def with_stackprof
  StackProf.run(mode: :object, raw: true, out: '/tmp/stackprof_objects.dump', interval: 1) do
    yield
  end
  puts '/tmp/stackprof_objects.dump dump created, please use "stackprof --text /tmp/stackprof_objects.dump" to investigate'
end

def with_chosen_profiler(&block)
  case (ENV['PROFILER'] || '').downcase
  when 'memory_profiler'
    profiler_method = :with_memory_profiler
  when 'stackprof'
    profiler_method = :with_stackprof
  else
    puts 'Set "PROFILER" to either "memory_profiler" or "stackprof"'
    exit 1
  end

  send(profiler_method, &block)
end
