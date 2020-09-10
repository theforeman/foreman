require "benchmark/benchmark_helper"

FactName.transaction do
  (0..100000).each do |x|
    FactName.connection.execute "INSERT INTO fact_names (name) values ('rand_fact_name_#{x}')"
  end
end

class StructuredFactImporter
  def fact_name_class
    FactName
  end
end

def generate_facts(total, unique_names = 0, structured_names = 0)
  facts = Hash[(1..total).map { |i| ["fact_#{i}", "value_#{i}"] }]
  (total..total + unique_names).map { |i| facts["fact_#{i}_#{Foreman.uuid}"] = "value_#{i}" }
  (total..total + structured_names).map { |i| facts[(["f#{i}"] * (i % 10)).join('::') + i.to_s] = "value_#{i}" }
  facts
end

Rails.logger.level = Logger::ERROR

foreman_benchmark do
  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 0)

    [::PuppetFactImporter, ::StructuredFactImporter].each do |importer|
      [200, 500].each do |total_facts|
        [0, 50].each do |unique_names|
          [0, 25].each do |structured_names|
            facts = generate_facts(total_facts, unique_names, structured_names)
            x.report("#{importer} (#{total_facts}) - #{unique_names} UN #{structured_names} SN") do
              host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")
              importer.new(host, facts).import!
              importer.new(host, {}).import!
            end
          end
        end
      end
    end
  end
end
