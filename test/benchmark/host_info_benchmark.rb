require File.expand_path('../../config/environment', __dir__)

Rails.logger.level = Logger::ERROR

Benchmark.ips do |x|
  host = Host.find_or_create_by!(name: "benchmark-host-info-1")

  (1..1000).each do |i|
    name = FactName.find_or_create_by!(name: "benchmark-#{i}")
    FactValue.find_or_create_by!(value: "some value", fact_name: name, host: host)
  end

  (1..1000).each do |i|
    HostParameter.find_or_create_by!(name: "benchmark-param-#{i}", value: "<%= #{i} * 13 %>", host: host)
  end

  x.config(time: 10, warmup: 2)
  # require 'profile'
  x.report("Thousand") do
    # Profiler__::start_profile
    host.info
    # Profiler__::stop_profile
  end
end
