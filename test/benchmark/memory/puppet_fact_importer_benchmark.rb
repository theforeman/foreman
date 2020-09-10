# frozen_string_literal: true

require "benchmark/memory/memory_benchmark_helper"

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

facts = generate_facts(200, 50, 25)
User.current = User.unscoped.find(1)

host = FactoryBot.create(:host, :name => "benchmark-#{Foreman.uuid}")

with_chosen_profiler do
  StructuredFactImporter.new(host, facts).import!
end
