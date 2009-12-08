#! /usr/bin/ruby
# a simple script which fetches external nodes from Foreman
# you can basically use anything that knows how to get http data, e.g. wget/curl etc.

# Foreman url
foreman_url="http://foreman:3000"

require 'net/http'

foreman_url += "/node/#{ARGV[0]}?format=yml"
url = URI.parse(foreman_url)
req = Net::HTTP::Get.new(foreman_url)
res = Net::HTTP.start(url.host, url.port) { |http|
  http.request(req)
}

case res
when Net::HTTPOK
  puts res.body
else
  $stderr.puts "Error retrieving node %s: %s" % [ARGV[0], res.class]
end


