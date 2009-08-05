#! /usr/bin/ruby
# a simple script which fetches external nodes from GNI
# you can basically use anything that knows how to get http data, e.g. wget/curl etc.

require 'net/http'

gni_host="localhost:3000"
Net::HTTP.get_print URI.parse "http://#{gni_host}/hosts/externalNodes?fqdn=#{ARGV[0]}"
