module Foreman::TelemetryHelper
  extend ActiveSupport::Concern

  def telemetry_increment_counter(name, value = 1, tags = {})
    Foreman::Telemetry.instance.increment_counter(name, value, tags)
  end

  def telemetry_set_gauge(name, value, tags = {})
    Foreman::Telemetry.instance.set_gauge(name, value, tags)
  end

  def telemetry_observe_histogram(name, value, tags = {})
    Foreman::Telemetry.instance.observe_histogram(name, value, tags)
  end

  # time spent in a block as histogram, in miliseconds by default
  def telemetry_duration_histogram(name, scale = 1000, tags = {}, results = nil)
    case scale
    when :ms, :msec, :miliseconds
      scale = 1000
    when :sec, :seconds
      scale = 1
    when :min, :minutes
      scale = 1 / 60
    end
    before = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
  ensure
    after = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    duration = (after - before) * scale
    telemetry_observe_histogram(name, duration, tags)
    results[name] = duration if results
  end
end
