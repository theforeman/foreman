require "benchmark/benchmark_helper"
require "deacon"

Rails.logger.level = Logger::ERROR
reg_one = 1
reg_two = 1
generator = Deacon::RandomGenerator.new

foreman_benchmark do
  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 2)

    x.report("raw performance") do
      Message.make_digest("Raw performance test string")
    end

    x.report("raw legacy") do
      Message.make_digest_legacy("Raw performance test string")
    end

    x.report("create message") do
      reg_one, firstname, lastname = generator.generate(reg_one)
      Message.find_or_create('A test test test test message: ' + firstname + ' ' + lastname)
    end

    x.report("create source") do
      reg_one, firstname, lastname = generator.generate(reg_one)
      Source.find_or_create('A test test test source message: ' + firstname + ' ' + lastname)
    end

    x.report("find message") do
      reg_two, firstname, lastname = generator.generate(reg_two)
      Message.find_or_create('A test test test test message: ' + firstname + ' ' + lastname)
    end

    x.report("find source") do
      reg_two, firstname, lastname = generator.generate(reg_two)
      Source.find_or_create('A test test test source message: ' + firstname + ' ' + lastname)
    end
  end
end

puts "No. of messages in db after test: #{Message.all.count}"
puts "Example message digest: #{Message.first.digest}"
puts "No. of sources in db after test: #{Source.all.count}"
puts "Example source digest: #{Source.first.digest}"
