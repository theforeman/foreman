#! /usr/bin/ruby
# a simple script which fetches external nodes from Torque
# you can basically use anything that knows how to get http data, e.g. wget/curl etc.

require 'net/http'

Torque_host="localhost:3000"
Net::HTTP.get_print URI.parse("http://#{Torque_host}/hosts/externalNodes?fqdn=#{ARGV[0]}")
