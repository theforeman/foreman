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

def random_facts(total, &block)
  Hash[(1..total).map(&block)]
end

Rails.logger.level = Logger::ERROR

foreman_benchmark do
  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 1)
    size = 300

    facts = random_facts(size) { |i| ["fact_#{i}", "value_#{i}"] }
    x.report("Plain puppet same facts: #{size}") do
      host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")
      PuppetFactImporter.new(host, facts).import!
    end

    host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")
    x.report("Plain puppet unique values: #{size}") do
      facts = random_facts(size) { |i| ["fact_#{i}", "value_#{i}_#{Foreman.uuid}"] }
      PuppetFactImporter.new(host, facts).import!
    end

    facts = random_facts(size) { |i| ["fact_#{i}_#{Foreman.uuid}", "value_#{i}_#{Foreman.uuid}"] }
    x.report("Plain puppet unique all: #{size}") do
      host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")
      PuppetFactImporter.new(host, facts).import!
    end

    facts = random_facts(size) { |i| ["a::b::c::d::ee::fact_#{i}_#{Foreman.uuid}", "value_#{i}_#{Foreman.uuid}"] }
    host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")
    x.report("Structured puppet unique all: #{size}") do
      PuppetFactImporter.new(host, facts).import!
    end
  end
end
