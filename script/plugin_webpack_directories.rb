#! /usr/bin/env ruby

require 'bundler'
require 'json'

PLUGIN_NAME_REGEXP = /foreman*|katello*/

config = { entries: {}, paths: [] }
Bundler.load.specs.each do |dep|
  # skip other rails engines that are not plugins
  # TOOD: Consider using the plugin registeration api?
  next unless dep.name =~ PLUGIN_NAME_REGEXP
  path = "#{dep.to_spec.full_gem_path}/webpack"
  entry = "#{path}/index.js"
  # some plugings share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if config[:paths].include?(path)
  if File.exist?(entry)
    bundle_name = dep.name.gsub(/-|_|#{PLUGIN_NAME_REGEXP}/,'')
    config[:entries][bundle_name] = entry
    config[:paths] << path
  end
end

puts config.to_json
