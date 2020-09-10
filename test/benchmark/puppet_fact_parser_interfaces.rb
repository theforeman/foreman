require "benchmark/benchmark_helper"

def generate_facts(total)
  {}.tap do |facts|
    facts['interfaces'] = (1..total).map { |i| "eth0_#{i}" }.join(',')
    (1..total).each do |i|
      facts["ipaddress_eth0_#{i}"] = "192.168.#{i / 255}.#{i % 255}"
      facts["macaddress_eth0_#{i}"] = "00:10:10:10:#{sprintf('%02X', i / 255)}:#{sprintf('%02X', i % 255)}"
      facts["mtu_eth0_#{i}"] = "255.255.255.0"
      facts["netmask_eth0_#{i}"] = "255.255.255.0"
      facts["network_eth0_#{i}"] = "192.168.#{i / 255}.0"
    end
  end
end

Rails.logger.level = Logger::ERROR

Setting::Provisioning.load_defaults

foreman_benchmark do
  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 0)

    [::PuppetFactParser].each do |parser|
      [1, 50, 500].each do |total_facts|
        facts = generate_facts(total_facts)
        x.report("#{parser} #{total_facts}") do
          parser.new(facts).interfaces
        end
      end
    end
  end
end
