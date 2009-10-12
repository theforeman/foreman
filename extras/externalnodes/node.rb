#! /usr/bin/ruby
# a simple script which fetches external nodes from Foreman
# you can basically use anything that knows how to get http data, e.g. wget/curl etc.

# Foreman url
url="http://foreman:3000"

require 'net/http'
Net::HTTP.get_print URI.parse("{url}/hosts/externalNodes?fqdn=#{ARGV[0]}")
