require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
require 'benchmark/ips'

UNIQUE_RECORDS = 1_000
LOGS_PER_REPORT = 100

random_strings = Array.new(UNIQUE_RECORDS)
(0..UNIQUE_RECORDS).each do |i|
  random_strings[i] = SecureRandom.hex
end

def make_report(random_strings, hostname, logs)
  base = {"config_report" => {
    "host" => hostname.to_s, "reported_at" => Time.now.utc.to_s,
    "status" => { "applied" => 0, "restarted" => 0, "failed" => 1, "failed_restarts" => 0, "skipped" => 0, "pending" => 0 },
    "metrics" => { "time" => { "config_retrieval" => 6.98906397819519, "total" => 13.8197405338287 }, "resources" => { "applied" => 0, "failed" => 1, "failed_restarts" => 0, "out_of_sync" => 0, "restarted" => 0, "scheduled" => 67, "skipped" => 0, "total" => 68 }, "changes" => { "total" => 0 } },
    "logs" => []
  }}
  (1..logs).each do |i|
    base["config_report"]["logs"].append(
      {
        "log" => {"sources" => {"source" => "Source #{i} #{random_strings[rand(UNIQUE_RECORDS)]}" },
        "messages" => { "message" => "Message #{i} #{random_strings[rand(UNIQUE_RECORDS)]}" },
        "level" => "err" },
      })
  end
  base
end

uri = URI.parse("http://localhost:3000/api/v2/config_reports")
headers = {'Content-Type': 'application/json'}
http = Net::HTTP.new(uri.host, uri.port)

Benchmark.ips do |x|
  x.config(:time => 10, :warmup => 0)
  x.report("import report via HTTP") do
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.basic_auth("admin", "changeme")
    request.body = make_report(random_strings, "host-reports", LOGS_PER_REPORT).to_json
    http.request(request)
  end
end
