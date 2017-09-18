#! /usr/bin/env ruby

require 'json'

if File.exist?(File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__))
  require 'bundler_ext'
  gemfile_in = File.expand_path(File.join(%w[.. .. Gemfile.in]), __FILE__)
  specs = BundlerExt::Gemfile.parse(gemfile_in, :all).map { |spec, value| value[:dep] }
else
  require 'bundler'
  specs = Bundler.load.specs
end

PLUGIN_NAME_REGEXP = /foreman*|katello*/
REMOVE_BUNDLE_NAME_PLUGINS = /foreman*/

config = { entries: {}, paths: [] }
specs.each do |dep|
  # skip other rails engines that are not plugins
  # TODO: Consider using the plugin registration api?
  if gemfile_in
    next unless dep =~ PLUGIN_NAME_REGEXP
    dep = dep.to_spec
  else
    next unless dep.name =~ PLUGIN_NAME_REGEXP
  end
  path = "#{dep.to_spec.full_gem_path}/webpack"
  entry = "#{path}/index.js"
  # some plugins share the same base directory (tasks-core and tasks, REX etc)
  # skip the plugin if its path is already included
  next if config[:paths].include?(path)
  if File.exist?(entry)
    bundle_name = dep.name.gsub(/-|_|#{REMOVE_BUNDLE_NAME_PLUGINS}/,'')
    config[:entries][bundle_name] = entry
    config[:paths] << path
  end
end

puts config.to_json
