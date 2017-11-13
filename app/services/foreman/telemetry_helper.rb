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
  def telemetry_duration_histogram(name, scale = 1000, tags = {})
    case scale
    when :ms, :msec, :miliseconds
      scale = 1000
    when :sec, :seconds
      scale = 1
    when :min, :minutes
      scale = 1 / 60
    end
    before = Time.now.to_f
    yield
  ensure
    after = Time.now.to_f
    telemetry_observe_histogram(name, (after - before) * scale, tags)
  end
end
